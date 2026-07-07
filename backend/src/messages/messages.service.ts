import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { SendMessageDto } from './dto/send-message.dto';
import { MessageChannel } from '@prisma/client';

@Injectable()
export class MessagesService {
  constructor(private prisma: PrismaService) {}

  async findAll(userId: string) {
    return this.prisma.message.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
      take: 100,
    });
  }

  async findConversations(userId: string) {
    const messages = await this.prisma.message.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
    });

    const conversations = new Map();
    for (const msg of messages) {
      const key = msg.conversationId || msg.fromNumber;
      if (!conversations.has(key)) {
        conversations.set(key, {
          id: key,
          fromNumber: msg.fromNumber,
          toNumber: msg.toNumber,
          channel: msg.channel,
          lastMessage: msg.content,
          lastMessageAt: msg.createdAt,
          unread: msg.direction === 'inbound' ? 1 : 0,
        });
      }
    }
    return Array.from(conversations.values());
  }

  async findByConversation(conversationId: string) {
    return this.prisma.message.findMany({
      where: { conversationId },
      orderBy: { createdAt: 'asc' },
    });
  }

  async send(userId: string, dto: SendMessageDto) {
    return this.prisma.message.create({
      data: {
        userId,
        channel: dto.channel as MessageChannel,
        fromNumber: '', // Will be set from user's Twilio number
        toNumber: dto.toNumber,
        content: dto.content,
        direction: 'outbound',
        conversationId: dto.conversationId,
      },
    });
  }

  async createFromWebhook(data: {
    userId: string;
    channel: any;
    fromNumber: string;
    toNumber: string;
    content: string;
    conversationId?: string;
  }) {
    return this.prisma.message.create({
      data: {
        userId: data.userId,
        channel: data.channel,
        fromNumber: data.fromNumber,
        toNumber: data.toNumber,
        content: data.content,
        direction: 'inbound',
        conversationId: data.conversationId,
      },
    });
  }
}
