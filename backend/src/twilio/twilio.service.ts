import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { AiService } from '../ai/ai.service';
import { CallsService } from '../calls/calls.service';

const twilio = require('twilio');
const VoiceResponse = twilio.twiml.VoiceResponse;

@Injectable()
export class TwilioService {
  constructor(
    private prisma: PrismaService,
    private aiService: AiService,
    private callsService: CallsService,
  ) {}

  getClient() {
    return twilio(
      process.env.TWILIO_ACCOUNT_SID,
      process.env.TWILIO_AUTH_TOKEN,
    );
  }

  async handleIncomingCall(callData: {
    CallSid: string;
    From: string;
    To: string;
    AccountSid: string;
  }): Promise<string> {
    const twiml = new VoiceResponse();

    const user = await this.prisma.user.findFirst({
      where: { businessPhone: callData.To },
      include: { settings: true },
    });

    const greeting = user?.settings?.greetingMessage ||
      'Hello, thank you for calling. How can I assist you today?';

    if (user) {
      await this.callsService.create({
        userId: user.id,
        callSid: callData.CallSid,
        caller: callData.From,
        callee: callData.To,
        status: 'HANDLED',
      });
    }

    twiml.say({ voice: user?.settings?.aiVoice || 'Polly.Joanna' }, greeting);

    twiml.gather({
      input: ['speech'],
      action: '/api/twilio/gather',
      speechTimeout: 'auto',
      speechModel: 'phone_call',
    });

    twiml.say('I did not hear anything. Please call back if you need assistance.');
    twiml.hangup();

    return twiml.toString();
  }

  async handleGather(gatherData: {
    CallSid: string;
    From: string;
    SpeechResult?: string;
    SpeechConfidence?: string;
    To: string;
  }): Promise<string> {
    const twiml = new VoiceResponse();
    const userSpeech = gatherData.SpeechResult || '';

    const user = await this.prisma.user.findFirst({
      where: { businessPhone: gatherData.To },
      include: { settings: true },
    });

    if (!userSpeech) {
      twiml.say('I did not catch that. Could you please repeat yourself?');
      twiml.gather({
        input: ['speech'],
        action: '/api/twilio/gather',
        speechTimeout: 'auto',
      });
      return twiml.toString();
    }

    const aiResult = await this.aiService.getReceptionistResponse(userSpeech, {
      businessName: user?.settings?.businessName || undefined,
      aiTone: user?.settings?.aiTone || 'friendly',
    });

    try {
      await this.callsService.updateBySid(gatherData.CallSid, {
        transcript: userSpeech,
        summary: aiResult.response,
        intent: aiResult.intent,
        outcome: aiResult.action,
      });
    } catch (_) { /* call may not exist in DB */ }

    twiml.say({ voice: user?.settings?.aiVoice || 'Polly.Joanna' }, aiResult.response);

    if (aiResult.intent === 'emergency' || aiResult.action === 'transfer') {
      const emergencyNumber = user?.settings?.emergencyNumber || process.env.TWILIO_PHONE_NUMBER;
      twiml.say('Please hold while I connect you to a human.');
      twiml.dial(emergencyNumber);

      try {
        await this.callsService.updateBySid(gatherData.CallSid, {
          status: 'ESCALATED',
          outcome: 'transferred_to_human',
        });
      } catch (_) { /* call may not exist in DB */ }
    } else if (aiResult.intent === 'booking') {
      twiml.say('Let me check our calendar. One moment please.');
      twiml.gather({
        input: ['speech', 'dtmf'],
        action: '/api/twilio/booking-gather',
        speechTimeout: 'auto',
        numDigits: 10,
        hints: 'date, time, appointment, book, schedule',
      });
    } else if (aiResult.action === 'complete') {
      twiml.say('Thank you for calling. Have a great day!');
      twiml.hangup();
    } else {
      twiml.gather({
        input: ['speech'],
        action: '/api/twilio/gather',
        speechTimeout: 'auto',
      });
    }

    return twiml.toString();
  }

  async handleBookingGather(gatherData: {
    CallSid: string;
    From: string;
    SpeechResult?: string;
    To: string;
  }): Promise<string> {
    const twiml = new VoiceResponse();
    const userSpeech = gatherData.SpeechResult || '';

    twiml.say('Thank you for the details. Your appointment request has been noted. We will confirm shortly.');
    twiml.hangup();

    return twiml.toString();
  }

  async handleRecording(recordingData: {
    CallSid: string;
    RecordingUrl: string;
    RecordingDuration: string;
  }): Promise<string> {
    const twiml = new VoiceResponse();

    try {
      await this.callsService.updateBySid(recordingData.CallSid, {
        voicemailUrl: recordingData.RecordingUrl,
        duration: parseInt(recordingData.RecordingDuration) || 0,
        status: 'VOICEMAIL',
      });
    } catch (_) { /* call may not exist in DB */ }

    twiml.say('Your message has been recorded. Goodbye.');
    twiml.hangup();

    return twiml.toString();
  }

  async getCallRecording(callSid: string): Promise<string | null> {
    try {
      const client = this.getClient();
      const recordings = await client.recordings.list({ callSid, limit: 1 });
      if (recordings.length > 0) {
        return `https://api.twilio.com/2010-04-01/Accounts/${process.env.TWILIO_ACCOUNT_SID}/Recordings/${recordings[0].sid}.mp3`;
      }
      return null;
    } catch {
      return null;
    }
  }
}
