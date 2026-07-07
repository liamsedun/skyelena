#!/bin/bash
# Quick script to start ngrok tunnel for Twilio webhook testing
# Install ngrok first: https://ngrok.com/download

echo "Starting ngrok tunnel for local backend testing..."
echo ""
echo "Make sure your backend is running: npm run start:dev"
echo ""

ngrok http 3000 --host-header=localhost

echo ""
echo "Once ngrok starts, copy the https://xxxx.ngrok.io URL"
echo "and set it as your Twilio voice webhook:"
echo "  https://xxxx.ngrok.io/api/twilio/voice"
