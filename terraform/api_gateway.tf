# Rest API
resource "aws_api_gateway_rest_api" "skuczynska-API" {
  name        = "skuczynska-API"
  description = "This is my API for images app"
}

resource "aws_api_gateway_resource" "images" {
  rest_api_id = aws_api_gateway_rest_api.skuczynska-API.id
  parent_id   = aws_api_gateway_rest_api.skuczynska-API.root_resource_id
  path_part   = "images"
}

resource "aws_api_gateway_method" "skuczynska-method-POST" {
  rest_api_id          = aws_api_gateway_rest_api.skuczynska-API.id
  resource_id          = aws_api_gateway_resource.images.id
  http_method          = "POST"
  authorization        = "NONE"
  api_key_required     = false
  request_validator_id = aws_api_gateway_request_validator.filename_validator.id
  request_models       = {
    "application/json" : aws_api_gateway_model.api_model.name
  }
}

# Integration
resource "aws_api_gateway_integration" "skuczynska-integration" {
  rest_api_id             = aws_api_gateway_rest_api.skuczynska-API.id
  resource_id             = aws_api_gateway_resource.images.id
  http_method             = aws_api_gateway_method.skuczynska-method-POST.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = aws_lambda_function.skuczynska-lambda-POST_presignedURL.invoke_arn
  #  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.skuczynska-lambda-POST_presignedURL.arn}/invocations"
  #  uri                     = "https://${aws_api_gateway_rest_api.skuczynska-API.id}.execute-api.eu-central-1.amazonaws.com/dev/images"
  #  uri                     = aws_api_gateway_resource.images.path_part
}


resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = aws_api_gateway_rest_api.skuczynska-API.id
  resource_id = aws_api_gateway_resource.images.id
  http_method = aws_api_gateway_method.skuczynska-method-POST.http_method
  status_code = "200"
  depends_on  = [aws_api_gateway_integration.skuczynska-integration]
}

resource "aws_api_gateway_model" "api_model" {
  rest_api_id  = aws_api_gateway_rest_api.skuczynska-API.id
  name         = "skuczynskaPresginedUrlModel"
  description  = "a JSON schema"
  content_type = "application/json"
  depends_on   = [aws_api_gateway_resource.images]

  schema = <<EOF
{
  "title": "PresignedURLRequestModel",
  "type": "object",
  "properties": {
      "filename": {"type": "string"}
  },
  "required": ["filename"]
}
EOF
}

resource "aws_api_gateway_request_validator" "filename_validator" {
  name                        = "filenameCheck"
  rest_api_id                 = aws_api_gateway_rest_api.skuczynska-API.id
  validate_request_body       = true
  validate_request_parameters = true
}

resource "aws_api_gateway_integration_response" "integration-response-POST" {
  rest_api_id = aws_api_gateway_rest_api.skuczynska-API.id
  resource_id = aws_api_gateway_resource.images.id
  http_method = aws_api_gateway_method.skuczynska-method-POST.http_method
  status_code = aws_api_gateway_method_response.response_200.status_code

  depends_on = [aws_api_gateway_method_response.response_200]
}

# Deployment
resource "aws_api_gateway_deployment" "skuczynska-deployment" {
  rest_api_id = aws_api_gateway_rest_api.skuczynska-API.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.skuczynska-API.body))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_api_gateway_integration.skuczynska-integration]
}

resource "aws_api_gateway_stage" "dev" {
  deployment_id = aws_api_gateway_deployment.skuczynska-deployment.id
  rest_api_id   = aws_api_gateway_rest_api.skuczynska-API.id
  stage_name    = "dev"
}
