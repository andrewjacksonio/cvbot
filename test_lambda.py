from lambda_handler import lambda_handler
import json

# Test with proper API Gateway event structure
test_event = {
    "httpMethod": "GET",
    "path": "/",
    "pathParameters": None,
    "queryStringParameters": None,
    "headers": {
        "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
        "Accept-Encoding": "gzip, deflate",
        "Accept-Language": "en-US,en;q=0.5",
        "Host": "example.com",
        "User-Agent": "Mozilla/5.0",
        "X-Forwarded-For": "192.168.1.1",
        "X-Forwarded-Port": "443",
        "X-Forwarded-Proto": "https"
    },
    "body": None,
    "isBase64Encoded": False,
    "requestContext": {
        "httpMethod": "GET",
        "path": "/",
        "stage": "prod",
        "requestId": "test-request-id",
        "identity": {
            "sourceIp": "192.168.1.1"
        }
    }
}

test_context = {
    "function_name": "test-function",
    "aws_request_id": "test-request-id"
}

print("Testing lambda handler...")
result = lambda_handler(test_event, test_context)
print(f"Status Code: {result.get('statusCode')}")
print(f"Headers: {result.get('headers', {})}")
if result.get('statusCode') == 200:
    print("Success! Body length:", len(str(result.get('body', ''))))
else:
    print("Error:", result.get('body', ''))
