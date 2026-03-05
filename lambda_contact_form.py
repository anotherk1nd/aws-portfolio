import json
import boto3
import os
import urllib.parse
from datetime import datetime

ses_client = boto3.client('ses', region_name='eu-central-1')

def lambda_handler(event, context):
    """
    Process contact form submissions and send email via SES
    """
    
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
            body = base64.b64decode(event['body']).decode('utf-8')
        else:
            body = event.get('body', '')
        
        # Parse URL encoded form data
        form_data = {}
        for pair in body.split('&'):
            if '=' in pair:
                key, value = pair.split('=', 1)
                form_data[key] = urllib.parse.unquote_plus(value)
        
        name = form_data.get('name', 'Unknown')
        email = form_data.get('email', 'noreply@example.com')
        message = form_data.get('message', 'No message')
        
        # Validate inputs
        if not name or not email or not message:
            return {
                'statusCode': 400,
                'headers': {
                    'Access-Control-Allow-Origin': '*',
                    'Content-Type': 'text/html'
                },
                'body': '<html><body><h1>Error</h1><p>All fields are required.</p><a href="/">Go back</a></body></html>'
            }
        
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
        
        # Return success page
        return {
            'statusCode': 200,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Content-Type': 'text/html'
            },
            'body': '''
            <html>
            <head>
                <title>Message Sent - Josh Security Engineer</title>
                <style>
                    body { font-family: Arial, sans-serif; max-width: 600px; margin: 50px auto; padding: 20px; }
                    h1 { color: #2ecc71; }
                    a { color: #3498db; text-decoration: none; }
                    a:hover { text-decoration: underline; }
                </style>
            </head>
            <body>
                <h1>✓ Message Sent Successfully!</h1>
                <p>Thank you for reaching out. I'll get back to you soon.</p>
                <p><a href="/">← Return to homepage</a></p>
            </body>
            </html>
            '''
        }
        
    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            'statusCode': 500,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Content-Type': 'text/html'
            },
            'body': f'''
            <html>
            <body>
                <h1>Error</h1>
                <p>Sorry, something went wrong. Please try again later.</p>
                <p><a href="/">Go back</a></p>
            </body>
            </html>
            '''
        }
