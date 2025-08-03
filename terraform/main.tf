
# Terraform configuration for AWS Bedrock Knowledge Base
resource "aws_bedrockagent_knowledge_base" "cvbot_knowledge_base" {
  name     = "cvbot-s3-knowledge-base"
  role_arn = aws_iam_role.cvbot_knowledge_base.arn
  knowledge_base_configuration {
    vector_knowledge_base_configuration {
      embedding_model_arn = "arn:${data.aws_partition.current.partition}:bedrock:${data.aws_region.current.name}::foundation-model/amazon.titan-embed-text-v1"

      embedding_model_configuration {
        bedrock_embedding_model_configuration {
          embedding_data_type = "FLOAT32"
        }
      }
    }
    type = "VECTOR"
  }
  storage_configuration {
    type = "S3_VECTORS"

    # s3_vectors_configuration {
    #   bucket_arn = "arn:aws:s3vectors:::cvbot-knowledge-base"
    #   index_name = "bedrock-knowledge-base-default-index"
    #   field_mapping {
    #     vector_field   = "bedrock-knowledge-base-default-vector"
    #     text_field     = "AMAZON_BEDROCK_TEXT"
    #     metadata_field = "AMAZON_BEDROCK_METADATA"
    #   }
    # }
  }
}

resource "aws_bedrockagent_data_source" "cvbot_knowledge_base_ds" {
  knowledge_base_id = aws_bedrockagent_knowledge_base.cvbot_knowledge_base.id
  name              = "cvbot-knowledge-base-data-source"
  data_source_configuration {
    type = "S3"
    s3_configuration {
      bucket_arn = "arn:aws:s3:::cvbot-knowledge-base"
    }
  }
  vector_ingestion_configuration {
    chunking_configuration {
      chunking_strategy = "NONE"
    }
  }
}

resource "aws_iam_role" "cvbot_knowledge_base" {
  assume_role_policy = data.aws_iam_policy_document.cvbot_knowledge_base_trust_policy.json
  name               = "CvbotKnowledgeBaseRole"
  description        = "Bedrock Knowledge Base access"
  path               = "/service-role/"
}

resource "aws_iam_role_policy" "cvbot_knowledge_base" {
  name   = "CvbotRolePolicy"
  policy = data.aws_iam_policy_document.cvbot_knowledge_base_role_permissions.json
  role   = aws_iam_role.cvbot_knowledge_base.id
}

data "aws_iam_policy_document" "cvbot_knowledge_base_trust_policy" {
  statement {
    sid     = "AmazonBedrockKnowledgeBaseTrustPolicy"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["bedrock.amazonaws.com"]
      type        = "Service"
    }
    condition {
      test     = "StringEquals"
      values   = [data.aws_caller_identity.current.account_id]
      variable = "aws:SourceAccount"
    }
    condition {
      test     = "ArnLike"
      values   = ["arn:${data.aws_partition.current.partition}:bedrock:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:knowledge-base/*"]
      variable = "aws:SourceArn"
    }
  }
}

data "aws_iam_policy_document" "cvbot_knowledge_base_role_permissions" {
  statement {
    sid     = "BedrockInvokeModelStatement"
    actions = [
      "bedrock:InvokeModel"
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:bedrock:${data.aws_region.current.name}::foundation-model/amazon.titan-embed-text-v1",
    ]
  }
  
  statement {
    sid     = "S3VectorsPermissions"
    actions = [
      "s3vectors:GetIndex",
      "s3vectors:QueryVectors",
      "s3vectors:PutVectors",
      "s3vectors:GetVectors",
      "s3vectors:DeleteVectors"
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:s3vectors:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:bucket/bedrock-knowledge-base-3nmlna/index/bedrock-knowledge-base-default-index"
    ]
    condition {
      test     = "StringEquals"
      values   = [data.aws_caller_identity.current.account_id]
      variable = "aws:ResourceAccount"
    }
  }
  
  statement {
    sid     = "S3Permissions"
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::cvbot-knowledge-base"
    ]
    condition {
      test     = "StringEquals"
      values   = [data.aws_caller_identity.current.account_id]
      variable = "aws:ResourceAccount"
    }
  }
}

# # IAM Policy for Bedrock access
# resource "aws_iam_policy" "bedrock_access_policy" {
#   name        = "${var.project_name}-bedrock-access-policy"
#   description = "Policy for Lambda to access AWS Bedrock services"
  
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "bedrock:InvokeModel",
#           "bedrock:InvokeModelWithResponseStream",
#           "bedrock:ListFoundationModels",
#           "bedrock:GetFoundationModel",
#           "bedrock:GetModelInvocationLoggingConfiguration"
#         ]
#         Resource = [
#           "arn:aws:bedrock:${data.aws_region.current.name}::foundation-model/*",
#           "arn:aws:bedrock:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
#         ]
#       },
#       {
#         Effect = "Allow"
#         Action = [
#           "bedrock:ListFoundationModels"
#         ]
#         Resource = "*"
#       }
#     ]
#   })
  
#   tags = {
#     Name = "${var.project_name}-bedrock-access-policy"
#   }
# }

# # Attach the Bedrock policy to the existing Lambda execution role
# resource "aws_iam_role_policy_attachment" "lambda_bedrock_policy" {
#   role       = data.aws_lambda_function.cvbot_lambda.role
#   policy_arn = aws_iam_policy.bedrock_access_policy.arn
# }

# # Optional: CloudWatch Logs policy for Lambda (if not already attached)
# resource "aws_iam_policy" "lambda_logs_policy" {
#   name        = "${var.project_name}-lambda-logs-policy"
#   description = "Policy for Lambda to write to CloudWatch Logs"
  
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "logs:CreateLogGroup",
#           "logs:CreateLogStream",
#           "logs:PutLogEvents"
#         ]
#         Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.lambda_function_name}:*"
#       }
#     ]
#   })
  
#   tags = {
#     Name = "${var.project_name}-lambda-logs-policy"
#   }
# }

# # Attach the CloudWatch Logs policy to the Lambda execution role
# resource "aws_iam_role_policy_attachment" "lambda_logs_policy" {
#   role       = data.aws_lambda_function.cvbot_lambda.role
#   policy_arn = aws_iam_policy.lambda_logs_policy.arn
# }
