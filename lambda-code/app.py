from flask import Flask, request, jsonify, render_template
import json
import os
from datetime import datetime

app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/health')
def health():
    return jsonify({"status": "healthy", "service": "cvbot"})

@app.route('/chat', methods=['POST'])
def chat():
    try:
        # Try to get JSON data with proper handling for Lambda/API Gateway
        try:
            data = request.get_json(force=True)
        except Exception:
            # Handle Base64 encoding from API Gateway
            try:
                import json as json_lib
                import base64
                
                raw_data = request.data
                if raw_data:
                    # Try to decode Base64 if it's encoded
                    try:
                        decoded_data = base64.b64decode(raw_data).decode('utf-8')
                        data = json_lib.loads(decoded_data)
                    except Exception:
                        # Try direct decode
                        data = json_lib.loads(raw_data.decode('utf-8'))
                else:
                    data = {}
            except Exception as parse_error:
                return jsonify({"error": f"Invalid JSON: {str(parse_error)}"}), 400
        
        if not data:
            return jsonify({"error": "No data provided"}), 400
        
        message = data.get('message', '')
        if not message:
            return jsonify({"error": "Message is required"}), 400
        
        # Simple response - always return "hello world"
        response = {
            "message": "hello world",
            "timestamp": datetime.now().isoformat()
        }
        
        return jsonify({
            "status": "success",
            "response": response
        })
        
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# AWS Lambda handler
def lambda_handler(event, context):
    try:
        from aws_lambda_wsgi import response
        return response(app, event, context)
    except ImportError:
        # Fallback for local development
        return {
            'statusCode': 500,
            'body': json.dumps({'error': 'aws_lambda_wsgi not installed'})
        }

# For local development - only run if this file is executed directly
if __name__ == '__main__':
    # Check if we're in a CDK context and skip starting server
    import sys
    import os
    
    # Don't start server if we're in CDK/AWS context
    if (os.environ.get('CDK_CONTEXT') or 
        'cdk' in ' '.join(sys.argv).lower() or 
        'aws' in ' '.join(sys.argv).lower() or
        any('cdk' in str(arg).lower() for arg in sys.argv)):
        print("Detected CDK context - skipping Flask server startup")
        sys.exit(0)
    
    port = int(os.environ.get('PORT', 5000))
    debug = os.environ.get('FLASK_DEBUG', 'True').lower() == 'true'
    app.run(host='0.0.0.0', port=port, debug=debug)
