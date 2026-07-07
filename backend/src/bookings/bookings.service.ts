import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateBookingDto, UpdateBookingDto } from './dto/create-booking.dto';
import { BookingStatus } from '@prisma/client';

@Injectable()
export class BookingsService {
  constructor(private prisma: PrismaService) {}

  async findAll(userId: string) {
    return this.prisma.booking.findMany({
      where: { userId },
      orderBy: { date: 'desc' },
      take: 50,
    });
  }

  async findUpcoming(userId: string) {
    const now = new Date();
    return this.prisma.booking.findMany({
      where: {
        userId,
        date: { gte: now },
        status: { in: ['PENDING', 'CONFIRMED'] },
      },
      orderBy: { date: 'asc' },
    });
  }

  async findById(id: string) {
    const booking = await this.prisma.booking.findUnique({ where: { id } });
    if (!booking) throw new NotFoundException('Booking not found');
    return booking;
  }

  async create(userId: string, dto: CreateBookingDto) {
    return this.prisma.booking.create({
      data: {
        userId,
        customerName: dto.customerName,
        customerPhone: dto.customerPhone,
        customerEmail: dto.customerEmail,
        title: dto.title,
        description: dto.description,
        date: new Date(dto.date),
        duration: dto.duration || 30,
        source: dto.source,
      },
    });
  }

  async update(id: string, dto: UpdateBookingDto) {
    const booking = await this.prisma.booking.findUnique({ where: { id } });
    if (!booking) throw new NotFoundException('Booking not found');
    return this.prisma.booking.update({
      where: { id },
      data: {
        ...dto,
        status: dto.status as BookingStatus,
        date: dto.date ? new Date(dto.date) : undefined,
      },
    });
  }

  async remove(id: string) {
    const booking = await this.prisma.booking.findUnique({ where: { id } });
    if (!booking) throw new NotFoundException('Booking not found');
    return this.prisma.booking.delete({ where: { id } });
  }
}
