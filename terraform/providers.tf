# AWS Bedrock and Lambda IAM Setup for CVBot
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  # S3 Backend for remote state storage
  backend "s3" {
    bucket         = "andrewjacksonio-terraform-state"
    key            = "cvbot/terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
  }
}

# Configure AWS Provider
provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = "CVBot"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}
