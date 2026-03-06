import json
import boto3
import os
import urllib.parse
import re
import html
from datetime import datetime

ses_client = boto3.client('ses', region_name='eu-central-1')

def error_response(error_message):
    """Return error redirect to contact page with error message"""
    website_url = os.environ.get('WEBSITE_URL')
    if not website_url:
        raise ValueError("WEBSITE_URL environment variable not set")
    
    encoded_error = urllib.parse.quote(error_message)
    
    return {
        'statusCode': 302,
        'headers': {
            'Location': f'{website_url}/contact?error={encoded_error}',
            'Cache-Control': 'no-cache'
        },
        'body': ''
    }

def lambda_handler(event, context):
    """
    Process contact form submissions and send email via SES
    """
    
    # Validate required environment variables
    website_url = os.environ.get('WEBSITE_URL')
    if not website_url:
        raise ValueError("WEBSITE_URL environment variable not set")
    
    # Handle CORS preflight
    if event.get('httpMethod') == 'OPTIONS':
        return {
            'statusCode': 200,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Methods': 'POST, OPTIONS'
            },
            'body': ''
        }
    
    try:
        # Parse form data
        if event.get('isBase64Encoded'):
            import base64
            body = base64.b64decode(event['body']).decode('utf-8')
        else:
            body = event.get('body', '')
        
        # Parse URL encoded form data
        form_data = {}
        for pair in body.split('&'):
            if '=' in pair:
                key, value = pair.split('=', 1)
                form_data[key] = urllib.parse.unquote_plus(value)
       
        # Extract and strip values
        name = form_data.get('name', '').strip()
        email = form_data.get('email', '').strip()
        message = form_data.get('message', '').strip()

        # Validate required fields
        if not name or not email or not message:
            return error_response("All fields are required")
        
        # Validate lengths
        if len(name) > 100:
            return error_response("Name too long (max 100 characters)")
        if len(email) > 100:
            return error_response("Email too long (max 100 characters)")
        if len(message) > 5000:
            return error_response("Message too long (max 5000 characters)")
        
        # Validate email format
        email_regex = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
        if not re.match(email_regex, email):
            return error_response("Invalid email format")
        
        # Sanitize inputs (prevent XSS if ever displayed)
        name = html.escape(name)
        email = html.escape(email)
        message = html.escape(message)
        
        # Send email via SES
        recipient_email = os.environ.get('RECIPIENT_EMAIL', 'hello@joshuafenech.de')
        
        response = ses_client.send_email(
            Source=recipient_email,  # Must be verified in SES
            Destination={
                'ToAddresses': [recipient_email]
            },
            Message={
                'Subject': {
                    'Data': f'Portfolio Contact Form: {name}',
                    'Charset': 'UTF-8'
                },
                'Body': {
                    'Text': {
                        'Data': f"""
New contact form submission from your portfolio website:

Name: {name}
Email: {email}
Date: {datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S')} UTC

Message:
{message}
                        """,
                        'Charset': 'UTF-8'
                    }
                }
            },
            ReplyToAddresses=[email]  # Reply-to is sender's email
        )
        
        # Return success redirect
        return {
            'statusCode': 302,
            'headers': {
                'Location': f'{website_url}/contact?message=sent',
                'Cache-Control': 'no-cache'
            },
            'body': ''
        }
        
    except Exception as e:
        print(f"Error: {str(e)}")
        return error_response("An error occurred. Please try again later.")
