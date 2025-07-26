# CVBot - AWS Lambda Web Application

A serverless CV/Resume analysis and generation bot built with Python Flask and AWS Lambda.

## Features

- **CV Analysis**: Analyze resume content for word count, sections, and suggestions
- **CV Generation**: Generate CV templates based on user information
- **Serverless**: Runs on AWS Lambda with API Gateway
- **Local Development**: Multiple options for local testing

## API Endpoints

- `GET /` - Welcome message and API information
- `GET /health` - Health check
- `POST /cv/analyze` - Analyze CV content
- `POST /cv/generate` - Generate CV from user data

## Local Development Options

### Option 1: Direct Flask Development

```powershell
# Install dependencies
pip install -r requirements.txt

# Run locally
python app.py
```

The app will be available at `http://localhost:5000`

### Option 2: AWS SAM Local

```powershell
# Install SAM CLI
pip install aws-sam-cli

# Build the application
sam build

# Start local API Gateway
sam local start-api

# Test specific function
sam local invoke CVBotFunction -e events/api-gateway-get.json
```

### Option 3: Serverless Framework Offline

```powershell
# Install Node.js dependencies
npm install

# Install Serverless globally
npm install -g serverless

# Start offline server
npm run dev
# or
serverless offline
```

## Testing

### Run Unit Tests
```powershell
python -m pytest tests/
```

### Test API Endpoints

**Analyze CV:**
```powershell
curl -X POST http://localhost:5000/cv/analyze `
  -H "Content-Type: application/json" `
  -d '{\"cv_text\": \"John Doe\\nSoftware Engineer\\nExperience: 5 years in Python\"}'
```

**Generate CV:**
```powershell
curl -X POST http://localhost:5000/cv/generate `
  -H "Content-Type: application/json" `
  -d '{\"user_info\": {\"name\": \"Jane Doe\", \"email\": \"jane@example.com\"}}'
```

## Environment Variables

Create a `.env` file for local development:
```
FLASK_DEBUG=True
PORT=5000
AWS_REGION=us-east-1
```

## Deployment

### Deploy with SAM
```powershell
sam build
sam deploy --guided
```

### Deploy with Serverless Framework
```powershell
npm run deploy
```

## AWS CDK Deployment

Deploy your Andrew Jackson CareerBot to AWS using CDK with custom domain support.

### Prerequisites

1. **AWS CLI configured** with your credentials:
   ```powershell
   aws configure
   ```

2. **Node.js installed** (for CDK CLI):
   ```powershell
   # Install CDK globally
   npm install -g aws-cdk
   ```

3. **Domain Setup**: Ensure `andrewjackson.io` is configured in Route53

### Deployment Steps

1. **Install CDK dependencies:**
   ```powershell
   pip install -r requirements-cdk.txt
   ```

2. **Bootstrap CDK (one-time setup):**
   ```powershell
   cdk bootstrap aws://097890748571/us-west-2
   ```

3. **Deploy the stack:**
   ```powershell
   cdk deploy CareerBotStack --app "python app_cdk.py"
   ```

   Or use the deployment script:
   ```powershell
   .\deploy.ps1
   ```

### What Gets Deployed

- **Lambda Function**: Your Flask app running on Python 3.8
- **API Gateway**: RESTful API with custom domain
- **SSL Certificate**: Automatically provisioned via ACM
- **Route53 Record**: `bot.andrewjackson.io` pointing to your API
- **CORS Configuration**: Enabled for web access

### Custom Domain

After deployment, your bot will be available at:
- **Production URL**: `https://bot.andrewjackson.io`
- **API Gateway URL**: Also provided in CDK outputs

### CDK Commands

```powershell
# View the changes before deployment
cdk diff CareerBotStack --app "python app_cdk.py"

# Deploy
cdk deploy CareerBotStack --app "python app_cdk.py"

# Destroy the stack (when needed)
cdk destroy CareerBotStack --app "python app_cdk.py"

# View stack outputs
aws cloudformation describe-stacks --stack-name CareerBotStack --region us-west-2
```

### Configuration

The deployment is configured for:
- **Account**: `097890748571`
- **Region**: `us-west-2`
- **Domain**: `bot.andrewjackson.io`
- **Hosted Zone**: `andrewjackson.io`

To change these settings, edit `app_cdk.py`.

## Project Structure

```
cvbot/
├── app.py                 # Main Flask application
├── requirements.txt       # Python dependencies
├── template.yaml         # SAM template
├── serverless.yml        # Serverless Framework config
├── package.json          # Node.js dependencies
├── .env                  # Environment variables
├── events/               # Test events for SAM
│   ├── api-gateway-get.json
│   └── cv-analyze-post.json
└── tests/                # Unit tests
    └── test_app.py
```

## Quick Start

1. **Clone and setup:**
   ```powershell
   git clone <your-repo>
   cd cvbot
   pip install -r requirements.txt
   ```

2. **Run locally:**
   ```powershell
   python app.py
   ```

3. **Test the API:**
   Visit `http://localhost:5000` in your browser

4. **Run tests:**
   ```powershell
   python -m pytest tests/
   ```

## Next Steps

- Add AI/ML capabilities for CV analysis
- Implement CV template generation
- Add user authentication
- Integrate with external APIs
- Add more comprehensive testing