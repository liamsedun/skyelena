import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class DashboardService {
  constructor(private prisma: PrismaService) {}

  async getStats(userId: string) {
    const now = new Date();
    const todayStart = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const todayEnd = new Date(todayStart.getTime() + 86400000);

    const [
      todayAppointments,
      totalCalls,
      missedCalls,
      todayCalls,
      totalMessages,
      unreadMessages,
      recentCalls,
      upcomingBookings,
      subscription,
    ] = await Promise.all([
      this.prisma.booking.count({
        where: {
          userId,
          date: { gte: todayStart, lt: todayEnd },
          NOT: { status: 'CANCELLED' },
        },
      }),
      this.prisma.call.count({ where: { userId } }),
      this.prisma.call.count({
        where: { userId, status: 'MISSED' },
      }),
      this.prisma.call.count({
        where: {
          userId,
          createdAt: { gte: todayStart, lt: todayEnd },
        },
      }),
      this.prisma.message.count({ where: { userId } }),
      this.prisma.message.count({
        where: { userId, direction: 'inbound', status: 'sent' },
      }),
      this.prisma.call.findMany({
        where: { userId },
        orderBy: { createdAt: 'desc' },
        take: 5,
      }),
      this.prisma.booking.findMany({
        where: {
          userId,
          date: { gte: now },
          status: { in: ['PENDING', 'CONFIRMED'] },
        },
        orderBy: { date: 'asc' },
        take: 5,
      }),
      this.prisma.subscription.findUnique({
        where: { userId },
        select: {
          tier: true,
          minutesUsed: true,
          minutesLimit: true,
          status: true,
        },
      }),
    ]);

    return {
      todayAppointments,
      totalCalls,
      missedCalls,
      todayCalls,
      totalMessages,
      unreadMessages,
      recentCalls,
      upcomingBookings,
      subscription,
    };
  }
}
