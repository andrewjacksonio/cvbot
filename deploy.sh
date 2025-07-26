#!/bin/bash

# Deploy script for Andrew Jackson CareerBot
echo "🚀 Deploying Andrew Jackson CareerBot to AWS..."

# Check if AWS CLI is configured
if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ AWS CLI not configured. Please run 'aws configure' first."
    exit 1
fi

# Check if CDK is installed
if ! command -v cdk &> /dev/null; then
    echo "📦 Installing AWS CDK..."
    npm install -g aws-cdk
fi

# Install Python CDK dependencies
echo "📦 Installing CDK dependencies..."
pip install -r requirements-cdk.txt

# Bootstrap CDK (only needed once per account/region)
echo "🔧 Bootstrapping CDK..."
cdk bootstrap aws://097890748571/us-west-2

# Deploy the stack
echo "🚀 Deploying CareerBot stack..."
cdk deploy CareerBotStack --app "python app_cdk.py" --require-approval never

echo "✅ Deployment complete!"
echo "🌐 Your CareerBot should be available at: https://bot.andrewjackson.io"
