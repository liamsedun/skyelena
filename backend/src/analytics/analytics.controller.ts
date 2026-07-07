import { Controller, Get, Param, Query, UseGuards } from '@nestjs/common';
import { AnalyticsService } from './analytics.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';

@Controller('analytics')
@UseGuards(JwtAuthGuard)
export class AnalyticsController {
  constructor(private analyticsService: AnalyticsService) {}

  @Get('calls')
  getCallAnalytics(
    @CurrentUser() user: any,
    @Query('range') range: '7d' | '30d' | '90d' = '30d',
  ) {
    return this.analyticsService.getCallAnalytics(user.id, range);
  }

  @Get('bookings')
  getBookingAnalytics(
    @CurrentUser() user: any,
    @Query('range') range: '7d' | '30d' | '90d' = '30d',
  ) {
    return this.analyticsService.getBookingAnalytics(user.id, range);
  }

  @Get('revenue')
  getRevenueAnalytics(@CurrentUser() user: any) {
    return this.analyticsService.getRevenueAnalytics(user.id);
  }
}
