#!/bin/bash
# Stripe Product & Price creation script
# Requires: stripe CLI (https://stripe.com/docs/stripe-cli)
# Run: stripe login first, then bash stripe-products.sh

echo "Creating Stripe Products and Prices..."
echo "========================================"

# Starter Plan
echo "Creating Starter Plan..."
STARTER=$(stripe products create \
  --name="Starter Plan" \
  --description="For solo professionals. 100 call minutes, AI answering, SMS, basic booking." \
  --metadata[plan_type]=subscription \
  --output=json)
STARTER_ID=$(echo $STARTER | grep -o '"id": "[^"]*"' | head -1 | cut -d'"' -f4)
echo "Product ID: $STARTER_ID"

STARTER_PRICE=$(stripe prices create \
  --product=$STARTER_ID \
  --unit-amount=2900 \
  --currency=usd \
  --recurring[interval]=month \
  --output=json)
STARTER_PRICE_ID=$(echo $STARTER_PRICE | grep -o '"id": "[^"]*"' | head -1 | cut -d'"' -f4)
echo "Starter Price ID: $STARTER_PRICE_ID"
echo ""

# Growth Plan
echo "Creating Growth Plan..."
GROWTH=$(stripe products create \
  --name="Growth Plan" \
  --description="For growing teams. 500 minutes, WhatsApp, smart routing, calendar sync." \
  --metadata[plan_type]=subscription \
  --output=json)
GROWTH_ID=$(echo $GROWTH | grep -o '"id": "[^"]*"' | head -1 | cut -d'"' -f4)
echo "Product ID: $GROWTH_ID"

GROWTH_PRICE=$(stripe prices create \
  --product=$GROWTH_ID \
  --unit-amount=7900 \
  --currency=usd \
  --recurring[interval]=month \
  --output=json)
GROWTH_PRICE_ID=$(echo $GROWTH_PRICE | grep -o '"id": "[^"]*"' | head -1 | cut -d'"' -f4)
echo "Growth Price ID: $GROWTH_PRICE_ID"
echo ""

# Metered Usage (Call Minutes)
echo "Creating Call Minutes (Metered)..."
USAGE=$(stripe products create \
  --name="Call Minutes" \
  --description="Metered call minutes usage billing." \
  --metadata[plan_type]=usage \
  --output=json)
USAGE_ID=$(echo $USAGE | grep -o '"id": "[^"]*"' | head -1 | cut -d'"' -f4)
echo "Product ID: $USAGE_ID"

USAGE_PRICE=$(stripe prices create \
  --product=$USAGE_ID \
  --unit-amount=8 \
  --currency=usd \
  --recurring[interval]=month \
  --recurring[usage_type]=metered \
  --output=json)
USAGE_PRICE_ID=$(echo $USAGE_PRICE | grep -o '"id": "[^"]*"' | head -1 | cut -d'"' -f4)
echo "Usage Price ID: $USAGE_PRICE_ID"
echo ""

echo "========================================"
echo "Add these to your .env file:"
echo "STRIPE_STARTER_PRICE_ID=$STARTER_PRICE_ID"
echo "STRIPE_GROWTH_PRICE_ID=$GROWTH_PRICE_ID"
echo "STRIPE_USAGE_PRICE_ID=$USAGE_PRICE_ID"
echo "========================================"
