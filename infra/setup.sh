#!/bin/bash
set -e

echo "========================================"
echo "  SkyElena - Setup Script"
echo "========================================"
echo ""

# Check prerequisites
command -v node >/dev/null 2>&1 || { echo "❌ Node.js is required. Install from https://nodejs.org"; exit 1; }
command -v npm >/dev/null 2>&1 || { echo "❌ npm is required."; exit 1; }

echo "✅ Node.js $(node -v)"
echo "✅ npm $(npm -v)"
echo ""

# Setup backend
echo "📦 Setting up backend..."
cd backend
npm install
echo ""

# Environment file
if [ ! -f .env ]; then
    cp .env.example .env
    echo "📝 Created .env file — please fill in your keys:"
    echo "   - TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN, TWILIO_PHONE_NUMBER"
    echo "   - OPENAI_API_KEY"
    echo "   - STRIPE_SECRET_KEY, STRIPE_WEBHOOK_SECRET"
    echo "   - STRIPE_STARTER_PRICE_ID, STRIPE_GROWTH_PRICE_ID, STRIPE_USAGE_PRICE_ID"
    echo ""
fi

# Prisma
echo "🗃️  Setting up database..."
npx prisma generate
echo ""
echo "👉 Run 'npx prisma migrate dev' to create database tables"
echo ""

# Start dev server
echo "🚀 To start the backend:"
echo "   cd backend && npm run start:dev"
echo ""
echo "📱 To start the mobile app:"
echo "   cd mobile && flutter pub get && flutter run"
echo ""

# Twilio setup guide
echo "========================================"
echo "  TWILIO SETUP"
echo "========================================"
echo "1. Create account at https://www.twilio.com"
echo "2. Buy a phone number with voice capabilities"
echo "3. Set the webhook URL in Twilio Console:"
echo "   https://your-api-url.com/api/twilio/voice"
echo "   (Use ngrok for local dev: ngrok http 3000)"
echo ""

# Stripe setup guide
echo "========================================"
echo "  STRIPE SETUP"
echo "========================================"
echo "1. Create account at https://dashboard.stripe.com"
echo "2. Go to Products → Add Product"
echo "   - Starter Plan: \$29/month (recurring)"
echo "   - Growth Plan: \$79/month (recurring)"
echo "   - Call Minutes: \$0.08/unit (metered usage)"
echo "3. Copy price IDs to .env"
echo "4. Set webhook endpoint:"
echo "   https://your-api-url.com/api/billing/webhook"
echo "   Events: invoice.paid, invoice.payment_failed, customer.subscription.deleted"
echo ""

echo "========================================"
echo "  SETUP COMPLETE"
echo "========================================"
