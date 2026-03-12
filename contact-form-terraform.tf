# Contact Form Lambda Function and API Gateway
# Add this to your main-with-waf.tf file

# IAM role for Lambda
resource "aws_iam_role" "contact_form_lambda" {
  name = "${var.bucket_name}-contact-form-lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "Contact Form Lambda Role"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# IAM policy for Lambda to use SES
resource "aws_iam_role_policy" "contact_form_lambda_ses" {
  name = "ses-send-email"
  role = aws_iam_role.contact_form_lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ses:SendEmail",
          "ses:SendRawEmail"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach basic Lambda execution policy
resource "aws_iam_role_policy_attachment" "contact_form_lambda_basic" {
  role       = aws_iam_role.contact_form_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda function
resource "aws_lambda_function" "contact_form" {
  filename      = "lambda_contact_form.zip"
  function_name = "${var.bucket_name}-contact-form"
  role          = aws_iam_role.contact_form_lambda.arn
  handler       = "lambda_contact_form.lambda_handler"
  runtime       = "python3.11"
  timeout       = 30
  # reserved_concurrent_executions = 10  # Rate limiting, 10 is min supported by aws lambda functions - not possible currently, only 10 total available 12/3/26
  source_code_hash = fileexists("lambda_contact_form.zip") ? filebase64sha256("lambda_contact_form.zip") : null

  environment {
    variables = {
      RECIPIENT_EMAIL = "hello@joshuafenech.de"
      WEBSITE_URL     = "https://d2ij5nb8hbhpx1.cloudfront.net"
    }
  }

  tags = {
    Name        = "Contact Form Handler"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "contact_form" {
  name              = "/aws/lambda/${aws_lambda_function.contact_form.function_name}"
  retention_in_days = 365

  tags = {
    Name        = "Contact Form Logs"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# API Gateway REST API
resource "aws_api_gateway_rest_api" "contact_form" {
  name        = "${var.bucket_name}-contact-api"
  description = "API for portfolio contact form"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = {
    Name        = "Contact Form API"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# API Gateway Resource
resource "aws_api_gateway_resource" "contact" {
  rest_api_id = aws_api_gateway_rest_api.contact_form.id
  parent_id   = aws_api_gateway_rest_api.contact_form.root_resource_id
  path_part   = "contact"
}

# API Gateway Method - POST
resource "aws_api_gateway_method" "contact_post" {
  rest_api_id   = aws_api_gateway_rest_api.contact_form.id
  resource_id   = aws_api_gateway_resource.contact.id
  http_method   = "POST"
  authorization = "NONE"
}

# API Gateway Method - OPTIONS (for CORS)
resource "aws_api_gateway_method" "contact_options" {
  rest_api_id   = aws_api_gateway_rest_api.contact_form.id
  resource_id   = aws_api_gateway_resource.contact.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# API Gateway Integration - POST
resource "aws_api_gateway_integration" "contact_post" {
  rest_api_id             = aws_api_gateway_rest_api.contact_form.id
  resource_id             = aws_api_gateway_resource.contact.id
  http_method             = aws_api_gateway_method.contact_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.contact_form.invoke_arn
}

# API Gateway Integration - OPTIONS
resource "aws_api_gateway_integration" "contact_options" {
  rest_api_id = aws_api_gateway_rest_api.contact_form.id
  resource_id = aws_api_gateway_resource.contact.id
  http_method = aws_api_gateway_method.contact_options.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

# API Gateway Method Response - OPTIONS
resource "aws_api_gateway_method_response" "contact_options" {
  rest_api_id = aws_api_gateway_rest_api.contact_form.id
  resource_id = aws_api_gateway_resource.contact.id
  http_method = aws_api_gateway_method.contact_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }

  response_models = {
    "application/json" = "Empty"
  }
}

# API Gateway Integration Response - OPTIONS
resource "aws_api_gateway_integration_response" "contact_options" {
  rest_api_id = aws_api_gateway_rest_api.contact_form.id
  resource_id = aws_api_gateway_resource.contact.id
  http_method = aws_api_gateway_method.contact_options.http_method
  status_code = aws_api_gateway_method_response.contact_options.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

# Lambda permission for API Gateway
resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.contact_form.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.contact_form.execution_arn}/*/*"
}

# API Gateway Deployment
resource "aws_api_gateway_deployment" "contact_form" {
  depends_on = [
    aws_api_gateway_integration.contact_post,
    aws_api_gateway_integration.contact_options
  ]

  rest_api_id = aws_api_gateway_rest_api.contact_form.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.contact.id,
      aws_api_gateway_method.contact_post.id,
      aws_api_gateway_method.contact_options.id,
      aws_api_gateway_integration.contact_post.id,
      aws_api_gateway_integration.contact_options.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

# API Gateway Stage
resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.contact_form.id
  rest_api_id   = aws_api_gateway_rest_api.contact_form.id
  stage_name    = "prod"

  tags = {
    Name        = "Production Stage"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# Outputs
output "contact_form_api_url" {
  description = "Contact form API endpoint"
  value       = "${aws_api_gateway_stage.prod.invoke_url}/contact"
}

output "lambda_function_name" {
  description = "Contact form Lambda function name"
  value       = aws_lambda_function.contact_form.function_name
}
