import { Controller, Post, Get, Body, UseGuards, Req, Res } from '@nestjs/common';
import { Request, Response } from 'express';
import { BillingService } from './billing.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { CreateSubscriptionDto } from './dto/create-subscription.dto';

@Controller('billing')
export class BillingController {
  constructor(private billingService: BillingService) {}

  @Post('create-checkout')
  @UseGuards(JwtAuthGuard)
  createCheckout(@CurrentUser() user: any, @Body() dto: CreateSubscriptionDto) {
    return this.billingService.createCheckoutSession(user.id, dto.tier);
  }

  @UseGuards(JwtAuthGuard)
  @Get('subscription')
  getSubscription(@CurrentUser() user: any) {
    return this.billingService.getSubscription(user.id);
  }

  @UseGuards(JwtAuthGuard)
  @Post('portal')
  getPortal(@CurrentUser() user: any) {
    return this.billingService.getBillingPortalUrl(user.id);
  }

  @Post('webhook')
  async handleWebhook(@Req() req: Request, @Res() res: Response) {
    const sig = req.headers['stripe-signature'] as string;
    let event;

    try {
      const Stripe = require('stripe');
      const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);
      event = stripe.webhooks.constructEvent(
        req.body,
        sig,
        process.env.STRIPE_WEBHOOK_SECRET,
      );
    } catch (err) {
      res.status(400).send(`Webhook Error: ${(err as Error).message}`);
      return;
    }

    await this.billingService.handleWebhook(event);
    res.json({ received: true });
  }
}
