# Data source to get current AWS account ID and region
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_partition" "current" {}

# Data source to get the existing Lambda function
data "aws_lambda_function" "cvbot_lambda" {
  function_name = var.lambda_function_name
}
