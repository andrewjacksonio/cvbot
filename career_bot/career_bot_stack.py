from aws_cdk import (
    Stack,
    aws_lambda as _lambda,
    aws_apigateway as apigateway,
    aws_certificatemanager as acm,
    aws_route53 as route53,
    aws_route53_targets as targets,
    Duration,
    CfnOutput,
)
from constructs import Construct
import os

class CareerBotStack(Stack):

    def __init__(self, scope: Construct, construct_id: str, domain_name: str, hosted_zone_name: str, **kwargs) -> None:
        super().__init__(scope, construct_id, **kwargs)

        # Get the hosted zone for andrewjackson.io
        hosted_zone = route53.HostedZone.from_lookup(
            self, "HostedZone",
            domain_name=hosted_zone_name
        )

        # Create SSL certificate for cvbot.andrewjackson.io
        certificate = acm.Certificate(
            self, "CareerBotCertificate",
            domain_name=domain_name,
            validation=acm.CertificateValidation.from_dns(hosted_zone),
            subject_alternative_names=[f"*.{hosted_zone_name}"]
        )

        # Create Lambda function
        lambda_function = _lambda.Function(
            self, "CareerBotFunction",
            runtime=_lambda.Runtime.PYTHON_3_9,
            handler="lambda_handler.lambda_handler",
            code=_lambda.Code.from_asset("lambda-code"),
            timeout=Duration.seconds(30),
            memory_size=512,
            environment={
                "FLASK_DEBUG": "False"
            }
        )

        # Create API Gateway
        api = apigateway.RestApi(
            self, "CareerBotApi",
            rest_api_name="Andrew Jackson CareerBot API",
            description="CareerBot API for chat functionality",
            domain_name=apigateway.DomainNameOptions(
                domain_name=domain_name,
                certificate=certificate,
                endpoint_type=apigateway.EndpointType.REGIONAL,
                security_policy=apigateway.SecurityPolicy.TLS_1_2
            ),
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

        # Create Route53 record to point cvbot.andrewjackson.io to API Gateway
        route53.ARecord(
            self, "CareerBotAliasRecord",
            zone=hosted_zone,
            record_name="cvbot",
            target=route53.RecordTarget.from_alias(
                targets.ApiGateway(api)
            )
        )

        # Output the API Gateway URL and custom domain
        CfnOutput(
            self, "ApiGatewayUrl",
            value=api.url,
            description="API Gateway URL"
        )

        CfnOutput(
            self, "CustomDomainUrl",
            value=f"https://{domain_name}",
            description="Custom Domain URL"
        )

        CfnOutput(
            self, "LambdaFunctionArn",
            value=lambda_function.function_arn,
            description="Lambda Function ARN"
        )
