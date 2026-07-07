# SkyElena

AI receptionist by **Skyhouse Accountants & Technologies (Olalekan Williams Edun)** — never miss a call again. AI-powered call answering, appointment booking, messaging, and smart routing for businesses.

## Architecture

```
skyelena/
├── backend/          # NestJS API (TypeScript)
│   ├── prisma/       # Database schema
│   └── src/          # API source code
│       ├── auth/     # JWT authentication
│       ├── calls/    # Call logs & Twilio
│       ├── messages/ # SMS/WhatsApp
│       ├── bookings/ # Appointment scheduling
│       ├── settings/ # Business settings
│       ├── ai/       # AI integration
│       ├── twilio/   # Voice AI webhooks
│       ├── billing/  # Stripe subscriptions
│       ├── websocket/# Real-time updates
│       └── dashboard/# Stats & analytics
├── mobile/           # Flutter App (Dart)
│   └── lib/         # App source code
│       ├── features/ # Auth, Dashboard, Calls, Messages, Bookings, Settings
│       ├── services/ # API, Auth, Socket
│       ├── models/   # Data models
│       └── widgets/  # Shared widgets
```

## Prerequisites

- Node.js 18+
- Flutter 3.0+
- PostgreSQL
- Twilio account (phone number)
- Gemini or OpenAI API key
- Stripe account

## Quick Start

### Backend

```bash
cd backend
npm install
cp .env.example .env   # Fill in your keys
npx prisma migrate dev
npm run start:dev
```

### Mobile

```bash
cd mobile
flutter pub get
flutter run
```

## API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/auth/signup` | POST | Create account |
| `/api/auth/login` | POST | Sign in |
| `/api/dashboard/stats` | GET | Dashboard stats |
| `/api/calls` | GET | Call history |
| `/api/messages` | GET | Messages |
| `/api/bookings` | GET/CRUD | Appointments |
| `/api/settings` | GET/PATCH | Business settings |
| `/api/twilio/voice` | POST | Incoming call webhook |
| `/api/twilio/gather` | POST | Speech gather |
| `/api/billing/subscription` | GET | Plan info |
| `/api/billing/create-checkout` | POST | Upgrade plan |

## Pricing Tiers

- **Starter**: $29/mo — 100 call minutes, AI answering, SMS, basic booking
- **Growth**: $79/mo — 500 minutes, WhatsApp, smart routing, calendar sync
- **Pro**: $149/mo — 1000+ minutes, multi-user, analytics, CRM
- **Enterprise**: Custom — unlimited, dedicated AI, white-label

## Twilio Voice AI Flow

1. Customer calls Twilio number
2. Twilio sends webhook to `/api/twilio/voice`
3. Backend returns TwiML greeting with speech gather
4. Customer speaks → `/api/twilio/gather` receives speech
5. OpenAI processes intent (booking/inquiry/emergency/message)
6. AI response spoken back to caller
7. On emergency → transfer to human; booking → collect details

## Stripe Billing Flow

1. User upgrades → creates Stripe Checkout session
2. Stripe webhook `checkout.session.completed` activates subscription
3. Call minutes tracked in DB; usage reported to Stripe
4. Stripe auto-invoices metered usage monthly
5. `invoice.paid` / `payment_failed` webhooks sync status
