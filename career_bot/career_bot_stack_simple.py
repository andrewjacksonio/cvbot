from aws_cdk import (
    Stack,
    aws_lambda as _lambda,
    aws_apigateway as apigateway,
    Duration,
    CfnOutput,
    BundlingOptions,
)
from constructs import Construct

class CareerBotStackSimple(Stack):

    def __init__(self, scope: Construct, construct_id: str, **kwargs) -> None:
        super().__init__(scope, construct_id, **kwargs)

        # Create Lambda function using root directory with proper bundling
        lambda_function = _lambda.Function(
            self, "CareerBotFunction",
            runtime=_lambda.Runtime.PYTHON_3_8,
            handler="lambda_handler.lambda_handler",
            code=_lambda.Code.from_asset(".", 
                exclude=[
                    "cdk.out*",
                    "cdk.context.json", 
                    "career_bot/*",
                    "__pycache__/*",
                    ".git/*",
                    "*.md",
                    "cdk.json",
                    "app_cdk*.py",
                    "requirements-cdk.txt",
                    "events/*",
                    "tests/*",
                    ".env",
                    ".gitignore",
                    "package.json",
                    "serverless.yml",
                    "template.yaml",
                    "node_modules/*",
                    "deploy*.ps1",
                    "deploy*.sh",
                    "lambda-code/*"  # Exclude the duplicate directory
                ],
                bundling=BundlingOptions(
                    image=_lambda.Runtime.PYTHON_3_8.bundling_image,
                    command=[
                        "bash", "-c",
                        "pip install -r requirements.txt -t /asset-output && cp -r . /asset-output && rm -rf /asset-output/lambda-code"
                    ]
                )
            ),
            timeout=Duration.seconds(30),
            memory_size=512,
            environment={
                "FLASK_DEBUG": "False"
            }
        )

        # Create API Gateway (without custom domain)
        api = apigateway.RestApi(
            self, "CareerBotApi",
            rest_api_name="Andrew Jackson CareerBot API",
            description="CareerBot API for chat functionality",
            default_cors_preflight_options=apigateway.CorsOptions(
                allow_origins=apigateway.Cors.ALL_ORIGINS,
                allow_methods=apigateway.Cors.ALL_METHODS,
                allow_headers=["Content-Type", "X-Amz-Date", "Authorization", "X-Api-Key"]
            ),
            binary_media_types=["*/*"]
        )

        # Create Lambda integration
        lambda_integration = apigateway.LambdaIntegration(
            lambda_function,
            proxy=True
        )

        # Add catch-all proxy resource to handle all routes (including root)
        api.root.add_proxy(
            default_integration=lambda_integration,
            any_method=True
        )

        # Add root resource method for the base path
        api.root.add_method(
            "GET", 
            lambda_integration
        )

        # Output the API Gateway URL
        CfnOutput(
            self, "ApiGatewayUrl",
            value=api.url,
            description="API Gateway URL - Your CareerBot will be available here"
        )

        CfnOutput(
            self, "LambdaFunctionArn",
            value=lambda_function.function_arn,
            description="Lambda Function ARN"
        )
