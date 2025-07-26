from app import app
import json

def lambda_handler(event, context):
    """Lambda handler that imports the Flask app without starting the dev server"""
    try:
        from aws_lambda_wsgi import response
        
        # Ensure event has required fields for aws_lambda_wsgi
        if 'queryStringParameters' not in event:
            event['queryStringParameters'] = None
        if 'pathParameters' not in event:
            event['pathParameters'] = None
        if 'headers' not in event:
            event['headers'] = {}
        if 'body' not in event:
            event['body'] = None
        if 'isBase64Encoded' not in event:
            event['isBase64Encoded'] = False
        if 'httpMethod' not in event:
            event['httpMethod'] = 'GET'
        if 'path' not in event:
            event['path'] = '/'
        if 'requestContext' not in event:
            event['requestContext'] = {
                'httpMethod': event.get('httpMethod', 'GET'),
                'path': event.get('path', '/'),
                'stage': 'prod',
                'requestId': 'lambda-request',
                'identity': {'sourceIp': '127.0.0.1'}
            }
            
        return response(app, event, context)
    except ImportError as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': f'aws_lambda_wsgi not installed: {str(e)}'})
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': f'Lambda error: {str(e)}'})
        }
