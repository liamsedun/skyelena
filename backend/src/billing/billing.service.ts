import { Injectable, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

const Stripe = require('stripe');

@Injectable()
export class BillingService {
  private stripe: any;

  constructor(private prisma: PrismaService) {
    this.stripe = new Stripe(process.env.STRIPE_SECRET_KEY);
  }

  private getPlanLimits(tier: string): { minutesLimit: number; priceId: string } {
    switch (tier) {
      case 'STARTER':
        return { minutesLimit: 100, priceId: process.env.STRIPE_STARTER_PRICE_ID || '' };
      case 'GROWTH':
        return { minutesLimit: 500, priceId: process.env.STRIPE_GROWTH_PRICE_ID || '' };
      case 'PRO':
        return { minutesLimit: 1000, priceId: '' };
      case 'FREE':
      default:
        return { minutesLimit: 50, priceId: '' };
    }
  }

  async createCheckoutSession(userId: string, tier: string) {
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user) throw new BadRequestException('User not found');

    const plan = this.getPlanLimits(tier);
    if (!plan.priceId) {
      throw new BadRequestException('Invalid tier selected');
    }

    let stripeCustomerId = user.stripeCustomerId;

    if (!stripeCustomerId) {
      const customer = await this.stripe.customers.create({
        email: user.email,
        name: user.name,
        metadata: { userId: user.id },
      });
      stripeCustomerId = customer.id;

      await this.prisma.user.update({
        where: { id: userId },
        data: { stripeCustomerId },
      });
    }

    const session = await this.stripe.checkout.sessions.create({
      customer: stripeCustomerId,
      payment_method_types: ['card'],
      mode: 'subscription',
      line_items: [
        {
          price: plan.priceId,
          quantity: 1,
        },
        {
          price: process.env.STRIPE_USAGE_PRICE_ID,
        },
      ],
      success_url: `${process.env.FRONTEND_URL || 'http://localhost:3000'}/settings?success=true`,
      cancel_url: `${process.env.FRONTEND_URL || 'http://localhost:3000'}/settings?canceled=true`,
      metadata: { userId, tier },
    });

    return { url: session.url, sessionId: session.id };
  }

  async handleWebhook(event: any) {
    switch (event.type) {
      case 'checkout.session.completed': {
        const session = event.data.object;
        const userId = session.metadata.userId;
        const tier = session.metadata.tier;
        const subscriptionId = session.subscription;

        if (userId) {
          const plan = this.getPlanLimits(tier);
          await this.prisma.subscription.update({
            where: { userId },
            data: {
              tier: tier as any,
              stripeSubId: subscriptionId,
              status: 'active',
              minutesLimit: plan.minutesLimit,
            },
          });
        }
        break;
      }

      case 'invoice.paid': {
        const invoice = event.data.object;
        if (invoice.subscription) {
          await this.prisma.subscription.updateMany({
            where: { stripeSubId: invoice.subscription },
            data: { status: 'active' },
          });
        }
        break;
      }

      case 'invoice.payment_failed': {
        const invoice = event.data.object;
        if (invoice.subscription) {
          await this.prisma.subscription.updateMany({
            where: { stripeSubId: invoice.subscription },
            data: { status: 'past_due' },
          });
        }
        break;
      }

      case 'customer.subscription.deleted': {
        const subscription = event.data.object;
        await this.prisma.subscription.updateMany({
          where: { stripeSubId: subscription.id },
          data: { tier: 'FREE', status: 'canceled', minutesLimit: 50 },
        });
        break;
      }
    }
  }

  async recordUsage(userId: string, minutes: number) {
    const sub = await this.prisma.subscription.findUnique({ where: { userId } });
    if (!sub) return;

    const newTotal = sub.minutesUsed + minutes;

    await this.prisma.subscription.update({
      where: { userId },
      data: { minutesUsed: newTotal },
    });

    if (sub.stripeSubId && newTotal > sub.minutesLimit) {
      try {
        const stripeSub = await this.stripe.subscriptions.retrieve(sub.stripeSubId);
        const usageItem = stripeSub.items.data.find(
          (item: any) => item.price.lookup_key === 'call_usage' || item.price.id === process.env.STRIPE_USAGE_PRICE_ID,
        );

        if (usageItem) {
          await this.stripe.subscriptionItems.createUsageRecord(
            usageItem.id,
            {
              quantity: minutes,
              timestamp: Math.floor(Date.now() / 1000),
              action: 'increment',
            },
          );
        }
      } catch (error) {
        console.error('Stripe usage recording error:', error);
      }
    }
  }

  async getSubscription(userId: string) {
    return this.prisma.subscription.findUnique({ where: { userId } });
  }

  async getBillingPortalUrl(userId: string) {
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user?.stripeCustomerId) {
      throw new BadRequestException('No billing account found');
    }

    const session = await this.stripe.billingPortal.sessions.create({
      customer: user.stripeCustomerId,
      return_url: `${process.env.FRONTEND_URL || 'http://localhost:3000'}/settings`,
    });

    return { url: session.url };
  }
}
