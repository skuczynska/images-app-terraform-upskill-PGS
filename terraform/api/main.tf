# Rest API
resource "aws_api_gateway_rest_api" "api" {
  name        = "${var.owner}-API"
  description = "This is my API for images app"
}

resource "aws_api_gateway_resource" "images" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "images"
}

resource "aws_api_gateway_method" "post" {
  rest_api_id          = aws_api_gateway_rest_api.api.id
  resource_id          = aws_api_gateway_resource.images.id
  http_method          = "POST"
  authorization        = "NONE"
  request_validator_id = aws_api_gateway_request_validator.filename_validator.id
  request_models       = {
    "application/json" : aws_api_gateway_model.api_model.name
  }
}

# Integration
resource "aws_api_gateway_integration" "integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.images.id
  http_method = aws_api_gateway_method.post.http_method

  integration_http_method = "POST"
  type                    = "AWS"
#  uri                     = var.presigned_url_arn
  uri                     = "arn:aws:lambda:eu-central-1:890769921003:function:skuczynska-presigned-url"
}


resource "aws_api_gateway_method_response" "post_200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.images.id
  http_method = aws_api_gateway_method.post.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "integration_response_post" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.images.id
  http_method = aws_api_gateway_method.post.http_method
  status_code = aws_api_gateway_method_response.post_200.status_code

  depends_on = [
    aws_api_gateway_integration.integration
  ]
}

resource "aws_api_gateway_model" "api_model" {
  rest_api_id  = aws_api_gateway_rest_api.api.id
  name         = "apimodel"
  description  = "a JSON schema"
  content_type = "application/json"

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
  name                        = "filename-check"
  rest_api_id                 = aws_api_gateway_rest_api.api.id
  validate_request_body       = true
  validate_request_parameters = true
}

# Deployment
resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    aws_api_gateway_integration.integration
  ]

  rest_api_id = aws_api_gateway_rest_api.api.id

  stage_name = var.stage
}
