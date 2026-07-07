import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { PrismaModule } from './prisma/prisma.module';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { CallsModule } from './calls/calls.module';
import { MessagesModule } from './messages/messages.module';
import { BookingsModule } from './bookings/bookings.module';
import { SettingsModule } from './settings/settings.module';
import { AiModule } from './ai/ai.module';
import { TwilioModule } from './twilio/twilio.module';
import { BillingModule } from './billing/billing.module';
import { WebsocketModule } from './websocket/websocket.module';
import { DashboardModule } from './dashboard/dashboard.module';
import { AnalyticsModule } from './analytics/analytics.module';
import { HealthController } from './health.controller';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    PrismaModule,
    AuthModule,
    UsersModule,
    CallsModule,
    MessagesModule,
    BookingsModule,
    SettingsModule,
    AiModule,
    TwilioModule,
    BillingModule,
    WebsocketModule,
    DashboardModule,
    AnalyticsModule,
  ],
  controllers: [HealthController],
})
export class AppModule {}
