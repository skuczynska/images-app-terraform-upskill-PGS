terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = var.region
}

data "archive_file" "lambda-POST-presignedURL-zip" {
  type        = "zip"
  source_file = "src/lambda_POST_presignedURL.py"
  output_path = "lambda-POST-presignedURL.zip"
}


resource "aws_iam_role" "skuczynska-lambda-role" {
  name               = "skuczynska-lambda-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
        },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}

EOF
}

resource "aws_cloudwatch_log_group" "skuczynska-lambda-POST_presignedURL" {
  name = "/aws/lambda/skuczynska-lambda-POST_presignedURL"
}

resource "aws_iam_role_policy" "skuczynska-api-gateway-policy" {
  name = "skuczynska-api-gateway-policy"
  role = aws_iam_role.skuczynska-lambda-role.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "execute-api:Invoke",
          "execute-api:ManageConnections"
        ],
        "Resource" : "arn:aws:execute-api:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "skuczynska-bucket-policy" {
  name = "skuczynska-bucket-policy"
  role = aws_iam_role.skuczynska-lambda-role.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:*",
          "s3-object-lambda:*"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "skuczynska-cloudwatch-policy" {
  name = "skuczynska-cloudwatch-policy"
  role = aws_iam_role.skuczynska-lambda-role.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "logs:*"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      }
    ]
  })
}

# Lambda
resource "aws_lambda_permission" "skuczynska-lambda-POST-permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.skuczynska-lambda-POST_presignedURL.function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
#  source_arn = "arn:aws:execute-api:${var.region}:${var.account_id}:${aws_api_gateway_rest_api.skuczynska-API.id}/*/${aws_api_gateway_method.skuczynska-POST-method.http_method}${aws_api_gateway_resource.skuczynska-resource.path_part}"
}

resource "aws_lambda_function" "skuczynska-lambda-POST_presignedURL" {
  filename         = "lambda-POST-presignedURL.zip"
  function_name    = "skuczynska-lambda-POST_presignedURL"
  role             = aws_iam_role.skuczynska-lambda-role.arn
  handler          = "lambda_POST_presignedURL.lambda_handler"
  source_code_hash = data.archive_file.lambda-POST-presignedURL-zip.output_base64sha256
  runtime          = "python3.8"
}

resource "aws_api_gateway_rest_api" "skuczynska-API" {
  name        = "skuczynska-API"
  description = "This is my API for images app"
}

resource "aws_api_gateway_resource" "skuczynska-resource" {
  rest_api_id = aws_api_gateway_rest_api.skuczynska-API.id
  parent_id   = aws_api_gateway_rest_api.skuczynska-API.root_resource_id
  path_part   = "images"
}


resource "aws_api_gateway_method" "skuczynska-POST-method" {
  rest_api_id   = aws_api_gateway_rest_api.skuczynska-API.id
  resource_id   = aws_api_gateway_resource.skuczynska-resource.id
  http_method   = "POST"
  authorization = "NONE"
  api_key_required = false
}

resource "aws_api_gateway_integration" "skuczynska-integration" {
  rest_api_id = aws_api_gateway_rest_api.skuczynska-API.id
  resource_id = aws_api_gateway_resource.skuczynska-resource.id
  http_method = aws_api_gateway_method.skuczynska-POST-method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.skuczynska-lambda-POST_presignedURL.invoke_arn
}



resource "aws_api_gateway_deployment" "skuczynska-deployment" {
  rest_api_id = aws_api_gateway_rest_api.skuczynska-API.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.skuczynska-API.body))
  }

  lifecycle {
    create_before_destroy = true
  }

   depends_on = [
    aws_api_gateway_integration.skuczynska-integration
  ]
}

resource "aws_api_gateway_stage" "dev" {
  deployment_id = aws_api_gateway_deployment.skuczynska-deployment.id
  rest_api_id   = aws_api_gateway_rest_api.skuczynska-API.id
  stage_name    = "dev"
}

resource "aws_s3_bucket" "skuczynska-bucket" {
  bucket = "skuczynska-bucket"
  acl    = "public-read"

  tags = {
    Name        = "skuczynska-bucket"
    Environment = "dev"
  }
}
