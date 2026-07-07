import { Injectable } from '@nestjs/common';
import OpenAI from 'openai';
import { GoogleGenerativeAI } from '@google/generative-ai';

@Injectable()
export class AiService {
  private openai: OpenAI | null = null;
  private gemini: GoogleGenerativeAI | null = null;

  constructor() {
    if (process.env.OPENAI_API_KEY) {
      this.openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });
    }
    if (process.env.GOOGLE_GEMINI_API_KEY) {
      this.gemini = new GoogleGenerativeAI(process.env.GOOGLE_GEMINI_API_KEY);
    }
  }

  async getReceptionistResponse(input: string, context?: {
    businessName?: string;
    aiTone?: string;
  }): Promise<{ response: string; intent: string; action: string }> {
    const tone = context?.aiTone || 'friendly';
    const businessName = context?.businessName || 'our business';
    const lower = input.toLowerCase();

    // 1) Try Gemini (free tier) if key is set
    if (this.gemini) {
      try {
        return await this.geminiResponse(input, businessName, tone);
      } catch (e) {
        console.warn('Gemini error, falling back:', (e as Error).message);
      }
    }

    // 2) Try OpenAI if key is set
    if (this.openai) {
      try {
        return await this.openaiResponse(input, businessName, tone);
      } catch (e) {
        console.warn('OpenAI error, falling back:', (e as Error).message);
      }
    }

    // 3) Rule-based fallback — no API key needed, completely free
    return this.ruleBasedResponse(input, lower);
  }

  private async geminiResponse(input: string, businessName: string, tone: string): Promise<any> {
    const model = this.gemini!.getGenerativeModel({ model: 'gemini-flash-latest' });
    const prompt = `You are SkyElena, an AI receptionist for ${businessName}. Be ${tone} and concise (max 2 sentences). Return ONLY valid JSON, no markdown, no code blocks.

User: "${input}"

{"response": "your spoken reply", "intent": "booking|inquiry|emergency|message|greeting|other", "action": "ask_details|confirm|transfer|complete"}`;
    const result = await model.generateContent(prompt);
    const text = result.response.text().replace(/```json\n?/g, '').replace(/```\n?/g, '').trim();
    const parsed = JSON.parse(text);
    return {
      response: parsed.response || 'How can I help you?',
      intent: parsed.intent || 'other',
      action: parsed.action || 'ask_details',
    };
  }

  private async openaiResponse(input: string, businessName: string, tone: string): Promise<any> {
    const prompt = `You are SkyElena, an AI receptionist for ${businessName}. Be ${tone} and concise (max 2 sentences).
User said: "${input}"
Respond JSON: { "response": "...", "intent": "booking|inquiry|emergency|message|greeting|other", "action": "ask_details|confirm|transfer|complete" }`;
    const completion = await this.openai!.chat.completions.create({
      model: 'gpt-3.5-turbo',
      messages: [
        { role: 'system', content: 'You are SkyElena, a professional AI receptionist. Respond in JSON.' },
        { role: 'user', content: prompt },
      ],
      temperature: 0.7,
      max_tokens: 200,
    });
    const text = completion.choices[0]?.message?.content || '{}';
    const cleaned = text.replace(/```json\n?/g, '').replace(/```\n?/g, '').trim();
    const parsed = JSON.parse(cleaned);
    return {
      response: parsed.response || 'How can I help you?',
      intent: parsed.intent || 'other',
      action: parsed.action || 'ask_details',
    };
  }

  private ruleBasedResponse(input: string, lower: string): { response: string; intent: string; action: string } {
    // Intent detection via keyword matching
    const patterns: { intent: string; keywords: string[]; response: string; action: string }[] = [
      {
        intent: 'emergency',
        keywords: ['emergency', 'urgent', 'emergency', 'help me', 'emergency assistance', 'asap', 'right now', 'immediate'],
        response: 'I understand this is urgent. I am connecting you to someone right away.',
        action: 'transfer',
      },
      {
        intent: 'booking',
        keywords: ['book', 'appointment', 'schedule', 'reservation', 'meeting', 'consultation', 'booking', 'when can i', 'i need to see'],
        response: 'I can help you schedule that. What day and time works best for you?',
        action: 'ask_details',
      },
      {
        intent: 'message',
        keywords: ['message', 'leave a message', 'tell them', 'let them know', 'take a message', 'leave message', 'send a message'],
        response: 'I will take a message and make sure it gets delivered. Please go ahead.',
        action: 'ask_details',
      },
      {
        intent: 'inquiry',
        keywords: ['price', 'cost', 'how much', 'service', 'offer', 'what do', 'do you', 'how does', 'hours', 'location', 'open', 'available'],
        response: 'Let me get that information for you. One moment please.',
        action: 'ask_details',
      },
      {
        intent: 'greeting',
        keywords: ['hello', 'hi', 'hey', 'good morning', 'good afternoon', 'good evening', 'how are you', 'hi there'],
        response: 'Hello! Thank you for calling. How can I assist you today?',
        action: 'ask_details',
      },
    ];

    for (const p of patterns) {
      if (p.keywords.some(k => lower.includes(k))) {
        return { response: p.response, intent: p.intent, action: p.action };
      }
    }

    return {
      response: 'I understand. Let me connect you with someone who can help further.',
      intent: 'other',
      action: 'transfer',
    };
  }

  async generateSummary(transcript: string): Promise<string> {
    if (!transcript) return 'No transcript available';

    if (this.gemini) {
      try {
        const model = this.gemini.getGenerativeModel({ model: 'gemini-flash-latest' });
        const result = await model.generateContent(`Summarize this call transcript in 1-2 sentences: "${transcript}"`);
        return result.response.text() || 'Summary unavailable';
      } catch { /* fall through */ }
    }

    if (this.openai) {
      try {
        const completion = await this.openai!.chat.completions.create({
          model: 'gpt-3.5-turbo',
          messages: [
            { role: 'system', content: 'Summarize in 1-2 sentences.' },
            { role: 'user', content: transcript },
          ],
          temperature: 0.3,
          max_tokens: 100,
        });
        return completion.choices[0]?.message?.content || 'Summary unavailable';
      } catch { /* fall through */ }
    }

    return `Call with ${transcript.substring(0, 50)}...`;
  }

  async generateAutoReply(message: string): Promise<string> {
    if (this.gemini) {
      try {
        const model = this.gemini.getGenerativeModel({ model: 'gemini-flash-latest' });
        const result = await model.generateContent(`Generate a brief helpful auto-reply to: "${message}"`);
        return result.response.text() || 'Thank you for your message. We will get back to you shortly.';
      } catch { /* fall through */ }
    }

    if (this.openai) {
      try {
        const completion = await this.openai!.chat.completions.create({
          model: 'gpt-3.5-turbo',
          messages: [
            { role: 'system', content: 'Generate a brief auto-reply, be friendly.' },
            { role: 'user', content: message },
          ],
          temperature: 0.5,
          max_tokens: 100,
        });
        return completion.choices[0]?.message?.content || 'Thank you for your message. We will get back to you shortly.';
      } catch { /* fall through */ }
    }

    return 'Thank you for your message. We will get back to you shortly.';
  }
}
