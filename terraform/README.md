# CVBot Terraform - AWS Bedrock Agent & Full AI Stack Setup

This Terraform configuration sets up a complete AWS Bedrock AI stack including agents, knowledge bases, and full IAM permissions for your existing CVBot Lambda function.

## Overview

This Terraform setup:
- **Creates a Bedrock Agent** with Amazon Nova Micro model
- **Grants full Bedrock access** to your Lambda function (all services)
- **Sets up knowledge base permissions** and S3 access
- **Configures S3 backend** for remote state management
- **Creates comprehensive IAM policies** for all Bedrock features
- **Enables CloudWatch logging** for debugging

## Prerequisites

1. **Terraform installed** (>= 1.0)
2. **AWS CLI configured** with appropriate permissions
3. **Existing Lambda function** deployed via CDK (CareerBotStack)
4. **S3 permissions** for backend state management

## Quick Start

### Step 1: Backend Setup (First Time Only)

1. **Initialize Terraform:**
   ```powershell
   cd terraform
   terraform init
   ```

2. **Create backend infrastructure:**
   ```powershell
   # Create S3 bucket for state management
   terraform apply -target=aws_s3_bucket.terraform_state
   ```

3. **Re-initialize with backend:**
   ```powershell
   terraform init
   # Answer "yes" when prompted to migrate state to S3
   ```

### Step 2: Main Deployment

1. **Create your variables file:**
   ```powershell
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Get your Lambda function name:**
   ```powershell
   aws lambda list-functions --query 'Functions[?contains(FunctionName, `CareerBot`)].FunctionName' --output text
   ```

3. **Update terraform.tfvars with your Lambda function name:**
   ```hcl
   lambda_function_name = "your-actual-lambda-function-name"
   ```

4. **Deploy the full stack:**
   ```powershell
   terraform plan
   terraform apply
   ```

## What Gets Created

### Core Infrastructure
- **S3 Backend**: Remote state storage with versioning and encryption

### Bedrock Resources
- **Bedrock Agent**: AI agent using Amazon Nova Micro model
- **IAM Role**: Execution role for the Bedrock agent
- **Knowledge Base Integration**: S3 access for document storage

### IAM Policies
- **Full Bedrock Access Policy**: Complete access to all Bedrock services
  - Model invocation (all foundation models)
  - Agent creation and management
  - Knowledge base operations
  - Custom model training
  - Guardrails and evaluation
- **CloudWatch Logs Policy**: Enables logging for debugging

### Permissions Granted
- **All Bedrock Operations**: Invoke, create, manage agents and knowledge bases
- **Model Access**: All foundation models including Nova, Claude, Titan
- **S3 Access**: Knowledge base document storage
- **Logging**: CloudWatch Logs access for monitoring

## Supported Models & Services

### Foundation Models
- **Amazon Nova** (Micro, Lite, Pro) - Primary model
- **Anthropic Claude 3** (Sonnet, Haiku, Opus)
- **Amazon Titan** (Text Express, Text Lite, Embeddings)
- **Meta Llama 2 & 3** (Various sizes)
- **Cohere Command** models
- **AI21 Jurassic** models

### Bedrock Services
- **Model Invocation**: Direct API calls to foundation models
- **Agents**: Complex multi-step AI workflows
- **Knowledge Bases**: RAG (Retrieval Augmented Generation)
- **Custom Models**: Fine-tuning and training
- **Guardrails**: Content filtering and safety
- **Evaluation**: Model performance testing

## Usage in Lambda Code

After applying this Terraform configuration, you can use all Bedrock services in your Lambda function:

### Basic Model Invocation
```python
import boto3
import json

# Initialize Bedrock client
bedrock = boto3.client('bedrock-runtime', region_name='us-west-2')

def invoke_nova(message):
    response = bedrock.invoke_model(
        modelId='amazon.nova-micro-v1',
        contentType='application/json',
        accept='application/json',
        body=json.dumps({
            "messages": [{"role": "user", "content": message}],
            "max_tokens": 1000,
            "temperature": 0.7
        })
    )
    
    result = json.loads(response['body'].read())
    return result['output']['message']['content'][0]['text']
```

### Bedrock Agent Integration
```python
# Initialize Bedrock agent client
bedrock_agent = boto3.client('bedrock-agent-runtime', region_name='us-west-2')

def invoke_agent(query, agent_id, alias_id):
    response = bedrock_agent.invoke_agent(
        agentId=agent_id,
        agentAliasId=alias_id,
        inputText=query,
        sessionId='unique-session-id'
    )
    
    # Process streaming response
    for event in response['completion']:
        if 'chunk' in event:
            chunk = event['chunk']
            if 'bytes' in chunk:
                return chunk['bytes'].decode('utf-8')
```

### Knowledge Base Queries
```python
def query_knowledge_base(query, kb_id):
    response = bedrock_agent.retrieve_and_generate(
        input={'text': query},
        retrieveAndGenerateConfiguration={
            'type': 'KNOWLEDGE_BASE',
            'knowledgeBaseConfiguration': {
                'knowledgeBaseId': kb_id,
                'modelArn': 'arn:aws:bedrock:us-west-2::foundation-model/amazon.nova-micro-v1'
            }
        }
    )
    
    return response['output']['text']
```

## Configuration

### Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `project_name` | Project name | `cvbot` |
| `environment` | Environment | `prod` |
| `aws_region` | AWS region | `us-west-2` |
| `lambda_function_name` | Lambda function name | *Must be set* |
| `bedrock_models` | List of models to access | Claude, Titan, Llama |

### Customization

The configuration is highly customizable through variables:

```hcl
# terraform.tfvars
project_name = "cvbot"
environment  = "prod"
aws_region   = "us-west-2"

# Your Lambda function (get from AWS CLI)
lambda_function_name = "CareerBotStack-CareerBotFunction2B61AFAE-W0cCUfjyJSdv"

# Bedrock models you want to use
bedrock_models = [
  "amazon.nova-micro-v1",
  "anthropic.claude-3-sonnet-20240229-v1:0",
  "amazon.titan-text-express-v1"
]

enable_bedrock_logging = true
```

## Commands

```powershell
# Backend setup (first time)
terraform init
terraform apply -target=aws_s3_bucket.terraform_state
terraform init  # Re-initialize with backend

# Regular operations
terraform plan    # Preview changes
terraform apply   # Deploy changes
terraform output  # View outputs
terraform destroy # Remove all resources (if needed)

# Specific operations
terraform state list                    # List all resources
terraform state show aws_bedrockagent_agent.cvbot  # Show agent details
terraform refresh                       # Sync state with AWS
```

## Security Notes

- **Full Bedrock Access**: Comprehensive permissions for all Bedrock services
- **Remote State**: S3 backend with encryption
- **No Hardcoded Secrets**: Uses AWS IAM roles and data sources
- **CloudWatch Logging**: Complete audit trail for debugging
- **Resource Tagging**: All resources tagged for cost management

## Troubleshooting

### Lambda Function Not Found
```bash
# List all Lambda functions
aws lambda list-functions --query 'Functions[].FunctionName'

# Find CareerBot functions specifically
aws lambda list-functions --query 'Functions[?contains(FunctionName, `CareerBot`)].FunctionName'
```

### Bedrock Agent Issues
- Check that the agent is properly created and prepared
- Verify the foundation model (amazon.nova-micro-v1) is available
- Ensure agent has proper IAM permissions

### Backend State Issues
```powershell
# If backend initialization fails
terraform init -reconfigure

# If you need to migrate state
terraform init -migrate-state
```

### Model Access
- Some Bedrock models require requesting access in the AWS Console
- Go to AWS Bedrock → Model access → Request access for specific models

## Integration with CDK

This Terraform configuration works alongside your existing CDK deployment:
- CDK manages the Lambda function and API Gateway
- Terraform manages the Bedrock IAM permissions
- Both can coexist without conflicts

## Next Steps

1. Apply this Terraform configuration
2. Update your `requirements.txt` to include `boto3`
3. Modify your Flask app to integrate with Bedrock
4. Test the integration locally and in Lambda
5. Deploy updated code via CDK

For more information on AWS Bedrock, see the [official documentation](https://docs.aws.amazon.com/bedrock/).
