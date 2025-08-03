# Project Configuration
variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "cvbot"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "prod"
}

# AWS Configuration
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
  default     = "097890748571"
}

# Lambda Configuration
variable "lambda_function_name" {
  description = "Name of the existing Lambda function"
  type        = string
  default     = "CareerBotStack-CareerBotFunction2B61AFAE-W0cCUfjyJSdv"
  # Note: You can get this from: aws lambda list-functions --query 'Functions[?contains(FunctionName, `CareerBot`)].FunctionName' --output text
}

# Bedrock Configuration
variable "bedrock_models" {
  description = "List of Bedrock models to allow access to"
  type        = list(string)
  default = [
    "anthropic.claude-3-sonnet-20240229-v1:0",
    "anthropic.claude-3-haiku-20240307-v1:0",
    "amazon.titan-text-express-v1",
    "amazon.titan-text-lite-v1",
    "meta.llama2-70b-chat-v1",
    "meta.llama2-13b-chat-v1"
  ]
}

variable "bedrock_agent_instruction" {
  type    = string
  default = "You are IT Professional named Andrew Jackson, you are 41 years old, born in July 1983 in Sydney but you live in Melbourne and are seeking a role as a senior or lead devops / platform engineering role.  The current date is July 2025.  Speak professionally and answer question about Andrew Jackson's career and experience from cvbot-s3-knowledge-base knowledge base"
}

variable "enable_bedrock_logging" {
  description = "Enable CloudWatch logging for Bedrock model invocations"
  type        = bool
  default     = true
}
