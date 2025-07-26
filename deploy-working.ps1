# Working deployment script for CareerBot

Write-Host "🚀 Deploying Andrew Jackson CareerBot..." -ForegroundColor Green

# Set environment variable to handle Node.js version
$env:JSII_SILENCE_WARNING_UNTESTED_NODE_VERSION="1"
Write-Host "✅ Node.js version warning silenced" -ForegroundColor Green

# Check AWS credentials
try {
    $identity = aws sts get-caller-identity | ConvertFrom-Json
    Write-Host "✅ AWS Account: $($identity.Account)" -ForegroundColor Green
} catch {
    Write-Host "❌ AWS credentials not configured. Run 'aws configure' first." -ForegroundColor Red
    exit 1
}

# Deploy simple version first (no custom domain)
Write-Host "🔧 Deploying simple version (API Gateway only)..." -ForegroundColor Yellow
try {
    cdk bootstrap aws://097890748571/us-west-2
    cdk deploy CareerBotStackSimple --app "python app_cdk_simple.py" --require-approval never
    Write-Host "✅ Simple deployment successful!" -ForegroundColor Green
} catch {
    Write-Host "❌ Simple deployment failed: $_" -ForegroundColor Red
    Write-Host "💡 Check the error above and try again" -ForegroundColor Yellow
    exit 1
}

# Ask if user wants to deploy with custom domain
$deployWithDomain = Read-Host "Deploy with custom domain bot.andrewjackson.io? (y/N)"
if ($deployWithDomain -eq "y" -or $deployWithDomain -eq "Y") {
    Write-Host "🌐 Deploying with custom domain..." -ForegroundColor Yellow
    try {
        cdk deploy CareerBotStack --app "python app_cdk.py" --require-approval never
        Write-Host "✅ Custom domain deployment successful!" -ForegroundColor Green
        Write-Host "🌐 Your bot is available at: https://bot.andrewjackson.io" -ForegroundColor Cyan
    } catch {
        Write-Host "❌ Custom domain deployment failed: $_" -ForegroundColor Red
        Write-Host "💡 Your bot is still available via the API Gateway URL from the simple deployment" -ForegroundColor Yellow
    }
}

Write-Host "✅ Deployment process complete!" -ForegroundColor Green
