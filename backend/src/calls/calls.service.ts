import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { UpdateCallDto } from './dto/update-call.dto';
import { CallStatus } from '@prisma/client';

@Injectable()
export class CallsService {
  constructor(private prisma: PrismaService) {}

  async findAll(userId: string) {
    return this.prisma.call.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
      take: 50,
    });
  }

  async findById(id: string) {
    const call = await this.prisma.call.findUnique({ where: { id } });
    if (!call) throw new NotFoundException('Call not found');
    return call;
  }

  async findBySid(callSid: string) {
    return this.prisma.call.findUnique({ where: { callSid } });
  }

  async create(data: {
    userId: string;
    callSid: string;
    caller: string;
    callee: string;
    status?: any;
  }) {
    return this.prisma.call.create({ data });
  }

  async update(id: string, dto: UpdateCallDto) {
    const call = await this.prisma.call.findUnique({ where: { id } });
    if (!call) throw new NotFoundException('Call not found');
    return this.prisma.call.update({ where: { id }, data: { ...dto, status: dto.status as CallStatus } });
  }

  async updateBySid(callSid: string, dto: UpdateCallDto) {
    return this.prisma.call.update({ where: { callSid }, data: { ...dto, status: dto.status as CallStatus } });
  }
}
