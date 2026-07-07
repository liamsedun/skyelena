import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class AnalyticsService {
  constructor(private prisma: PrismaService) {}

  async getCallAnalytics(userId: string, range: '7d' | '30d' | '90d' = '30d') {
    const now = new Date();
    const startDate = new Date(now);
    startDate.setDate(startDate.getDate() - (range === '7d' ? 7 : range === '90d' ? 90 : 30));

    const calls = await this.prisma.call.findMany({
      where: {
        userId,
        createdAt: { gte: startDate },
      },
      orderBy: { createdAt: 'asc' },
    });

    const totalCalls = calls.length;
    const answeredCalls = calls.filter(c => c.status === 'HANDLED').length;
    const missedCalls = calls.filter(c => c.status === 'MISSED').length;
    const escalatedCalls = calls.filter(c => c.status === 'ESCALATED').length;
    const voicemails = calls.filter(c => c.status === 'VOICEMAIL').length;

    // Daily breakdown
    const dailyMap = new Map<string, { date: string; total: number; answered: number; missed: number }>();
    for (const call of calls) {
      const day = call.createdAt.toISOString().split('T')[0];
      const entry = dailyMap.get(day) || { date: day, total: 0, answered: 0, missed: 0 };
      entry.total++;
      if (call.status === 'HANDLED') entry.answered++;
      if (call.status === 'MISSED') entry.missed++;
      dailyMap.set(day, entry);
    }

    const averageDuration = totalCalls > 0
      ? Math.round(calls.reduce((sum, c) => sum + c.duration, 0) / totalCalls)
      : 0;

    const answerRate = totalCalls > 0 ? Math.round((answeredCalls / totalCalls) * 100) : 0;

    return {
      period: range,
      totalCalls,
      answeredCalls,
      missedCalls,
      escalatedCalls,
      voicemails,
      answerRate,
      averageDuration,
      dailyBreakdown: Array.from(dailyMap.values()),
    };
  }

  async getBookingAnalytics(userId: string, range: '7d' | '30d' | '90d' = '30d') {
    const now = new Date();
    const startDate = new Date(now);
    startDate.setDate(startDate.getDate() - (range === '7d' ? 7 : range === '90d' ? 90 : 30));

    const bookings = await this.prisma.booking.findMany({
      where: {
        userId,
        createdAt: { gte: startDate },
      },
    });

    const total = bookings.length;
    const confirmed = bookings.filter(b => b.status === 'CONFIRMED').length;
    const cancelled = bookings.filter(b => b.status === 'CANCELLED').length;
    const completed = bookings.filter(b => b.status === 'COMPLETED').length;
    const pending = bookings.filter(b => b.status === 'PENDING').length;

    const conversionRate = total > 0 ? Math.round(((confirmed + completed) / total) * 100) : 0;

    // Source breakdown
    const sourceMap = new Map<string, number>();
    for (const b of bookings) {
      const source = b.source || 'web';
      sourceMap.set(source, (sourceMap.get(source) || 0) + 1);
    }

    return {
      period: range,
      totalBookings: total,
      confirmed,
      cancelled,
      completed,
      pending,
      conversionRate,
      sourceBreakdown: Object.fromEntries(sourceMap),
    };
  }

  async getRevenueAnalytics(userId: string) {
    const sub = await this.prisma.subscription.findUnique({ where: { userId } });
    if (!sub) return null;

    const tierPrices: Record<string, number> = {
      FREE: 0,
      STARTER: 29,
      GROWTH: 79,
      PRO: 149,
      ENTERPRISE: 299,
    };

    const monthlyRecurring = tierPrices[sub.tier] || 0;
    const overageMinutes = Math.max(0, sub.minutesUsed - sub.minutesLimit);
    const estimatedOverage = overageMinutes * 0.08;

    return {
      plan: sub.tier,
      monthlyRecurringRevenue: monthlyRecurring,
      minutesUsed: sub.minutesUsed,
      minutesLimit: sub.minutesLimit,
      overageMinutes,
      estimatedOverageRevenue: Math.round(estimatedOverage * 100) / 100,
      estimatedTotalRevenue: Math.round((monthlyRecurring + estimatedOverage) * 100) / 100,
      status: sub.status,
    };
  }
}
