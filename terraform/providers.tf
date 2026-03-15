# AWS Bedrock and Lambda IAM Setup for CVBot
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  # Terraform Cloud backend for remote state + remote runs
  backend "remote" {
    organization = "andrewjacksonio"

    workspaces {
      name = "cvbot"
    }
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
