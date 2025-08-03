# # Lambda Function Information
# output "lambda_function_name" {
#   description = "Name of the Lambda function"
#   value       = data.aws_lambda_function.cvbot_lambda.function_name
# }

# output "lambda_function_arn" {
#   description = "ARN of the Lambda function"
#   value       = data.aws_lambda_function.cvbot_lambda.arn
# }

# output "lambda_execution_role_arn" {
#   description = "ARN of the Lambda execution role"
#   value       = data.aws_lambda_function.cvbot_lambda.role
# }

# # Bedrock IAM Policy Information
# output "bedrock_policy_arn" {
#   description = "ARN of the Bedrock access policy"
#   value       = aws_iam_policy.bedrock_access_policy.arn
# }

# output "bedrock_policy_name" {
#   description = "Name of the Bedrock access policy"
#   value       = aws_iam_policy.bedrock_access_policy.name
# }

# # CloudWatch Logs Policy Information
# output "logs_policy_arn" {
#   description = "ARN of the CloudWatch Logs policy"
#   value       = aws_iam_policy.lambda_logs_policy.arn
# }

# # Bedrock Service Information
# output "available_bedrock_models" {
#   description = "List of Bedrock models configured for access"
#   value       = var.bedrock_models
# }

# output "bedrock_region" {
#   description = "AWS region where Bedrock is configured"
#   value       = data.aws_region.current.name
# }

# # Instructions for Lambda Code
# output "lambda_integration_instructions" {
#   description = "Instructions for integrating Bedrock in your Lambda code"
#   value = <<-EOT
#     To use Bedrock in your Lambda function, add boto3 to your requirements.txt and use:
    
#     import boto3
    
#     # Initialize Bedrock client
#     bedrock = boto3.client('bedrock-runtime', region_name='${data.aws_region.current.name}')
    
#     # Example: Invoke Claude model
#     response = bedrock.invoke_model(
#         modelId='anthropic.claude-3-sonnet-20240229-v1:0',
#         contentType='application/json',
#         accept='application/json',
#         body=json.dumps({
#             "anthropic_version": "bedrock-2023-05-31",
#             "max_tokens": 1000,
#             "messages": [
#                 {
#                     "role": "user",
#                     "content": "Your message here"
#                 }
#             ]
#         })
#     )
    
#     result = json.loads(response['body'].read())
#   EOT
# }
