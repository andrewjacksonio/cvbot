# Deploy script for Andrew Jackson CareerBot (Windows PowerShell)

Write-Host "🚀 Deploying Andrew Jackson CareerBot to AWS..." -ForegroundColor Green

# Check if AWS CLI is configured
try {
    aws sts get-caller-identity | Out-Null
    Write-Host "✅ AWS CLI configured" -ForegroundColor Green
} catch {
    Write-Host "❌ AWS CLI not configured. Please run 'aws configure' first." -ForegroundColor Red
    exit 1
}

# Check if CDK is installed
if (-not (Get-Command cdk -ErrorAction SilentlyContinue)) {
    Write-Host "📦 Installing AWS CDK..." -ForegroundColor Yellow
    npm install -g aws-cdk
}

# Install Python CDK dependencies
Write-Host "📦 Installing CDK dependencies..." -ForegroundColor Yellow
pip install -r requirements-cdk.txt

# Bootstrap CDK (only needed once per account/region)
Write-Host "🔧 Bootstrapping CDK..." -ForegroundColor Yellow
cdk bootstrap aws://097890748571/us-west-2

# Deploy the stack
Write-Host "🚀 Deploying CareerBot stack..." -ForegroundColor Yellow
cdk deploy CareerBotStack --app "python app_cdk.py" --require-approval never

Write-Host "✅ Deployment complete!" -ForegroundColor Green
Write-Host "🌐 Your CareerBot should be available at: https://bot.andrewjackson.io" -ForegroundColor Cyan
