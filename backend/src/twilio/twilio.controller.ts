import { Controller, Post, Req, Res, RawBodyRequest } from '@nestjs/common';
import { Request, Response } from 'express';
import { TwilioService } from './twilio.service';

@Controller('twilio')
export class TwilioController {
  constructor(private twilioService: TwilioService) {}

  @Post('voice')
  async handleVoice(@Req() req: any, @Res() res: Response) {
    const twiml = await this.twilioService.handleIncomingCall({
      CallSid: req.body.CallSid,
      From: req.body.From,
      To: req.body.To,
      AccountSid: req.body.AccountSid,
    });

    res.type('text/xml');
    res.send(twiml);
  }

  @Post('gather')
  async handleGather(@Req() req: any, @Res() res: Response) {
    const twiml = await this.twilioService.handleGather({
      CallSid: req.body.CallSid,
      From: req.body.From,
      SpeechResult: req.body.SpeechResult,
      SpeechConfidence: req.body.Confidence,
      To: req.body.To,
    });

    res.type('text/xml');
    res.send(twiml);
  }

  @Post('booking-gather')
  async handleBookingGather(@Req() req: any, @Res() res: Response) {
    const twiml = await this.twilioService.handleBookingGather({
      CallSid: req.body.CallSid,
      From: req.body.From,
      SpeechResult: req.body.SpeechResult,
      To: req.body.To,
    });

    res.type('text/xml');
    res.send(twiml);
  }

  @Post('recording')
  async handleRecording(@Req() req: any, @Res() res: Response) {
    const twiml = await this.twilioService.handleRecording({
      CallSid: req.body.CallSid,
      RecordingUrl: req.body.RecordingUrl,
      RecordingDuration: req.body.RecordingDuration,
    });

    res.type('text/xml');
    res.send(twiml);
  }
}
