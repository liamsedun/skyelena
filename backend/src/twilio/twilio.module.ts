import { Module } from '@nestjs/common';
import { TwilioController } from './twilio.controller';
import { TwilioService } from './twilio.service';
import { AiModule } from '../ai/ai.module';
import { CallsModule } from '../calls/calls.module';

@Module({
  imports: [AiModule, CallsModule],
  controllers: [TwilioController],
  providers: [TwilioService],
  exports: [TwilioService],
})
export class TwilioModule {}
