resource "aws_lambda_function" "presigned_url" {
  filename         = "presigned_url.zip"
  function_name    = "${var.owner}-presigned-url"
  role             = aws_iam_role.presigned_url.arn
  handler          = "lambda_presigned_url.lambda_handler"
  source_code_hash = data.archive_file.presigned_url.output_base64sha256
  runtime          = "python3.8"

  depends_on = [aws_iam_role.presigned_url]
}

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
  uri                     = aws_lambda_function.presigned_url.invoke_arn
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


resource "aws_lambda_permission" "presigned_url" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.presigned_url.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = aws_api_gateway_rest_api.api.arn
}

resource "aws_iam_role" "presigned_url" {
  name                = "${var.owner}-presigned-url"
  assume_role_policy  = data.aws_iam_policy_document.lambda_assume.json
  managed_policy_arns = [
    aws_iam_policy.s3_put_object.arn,
    data.aws_iam_policy.cloudwatch_full_access.arn,
  ]
}

resource "aws_lambda_function" "resize" {
  filename         = "modyf_image.zip"
  function_name    = "${var.owner}-lambda-resize"
  role             = aws_iam_role.resize.arn
  handler          = "lambda_modyf_image.lambda_handler"
  source_code_hash = data.archive_file.modyf_image.output_base64sha256

  layers = [aws_lambda_layer_version.pillow_layer.arn]

  runtime = "python3.8"
}

resource "aws_cloudwatch_log_group" "cloudwatch_group_resize" {
  name = "/aws/lambda/${var.owner}-lambda-resize"
}

resource "aws_iam_role" "resize" {
  name                = "${var.owner}-role-resize"
  assume_role_policy  = data.aws_iam_policy_document.lambda_assume.json
  managed_policy_arns = [
    aws_iam_policy.s3_put_object.arn,
    aws_iam_policy.sqs_send_msg.arn,
    data.aws_iam_policy.cloudwatch_full_access.arn,
    aws_iam_policy.sns.arn
  ]
}

resource "aws_lambda_function" "sqs_to_dynamo" {
  filename         = "to_dynamo.zip"
  function_name    = "${var.owner}-lambda-to-dynamo-payload"
  role             = aws_iam_role.sqs_to_dynamo.arn
  handler          = "lambda_to_dynamo_payload.lambda_handler"
  source_code_hash = data.archive_file.to_dynamo.output_base64sha256

  runtime = "python3.8"
}

resource "aws_iam_role" "sqs_to_dynamo" {
  name                = "${var.owner}-role-sqs-to-dynamo"
  assume_role_policy  = data.aws_iam_policy_document.lambda_assume.json
  managed_policy_arns = [
    aws_iam_policy.dynamodb_put_item.arn,
    data.aws_iam_policy.cloudwatch_full_access.arn,
    data.aws_iam_policy.sqs_full_access.arn
  ]
}


resource "aws_lambda_layer_version" "pillow_layer" {
  filename   = "pillow.zip"
  layer_name = "${var.owner}-pillow-layer"

  compatible_runtimes = ["python3.8"]

}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.resize.arn
  principal     = "s3.amazonaws.com"
  source_arn    = var.bucket_resized_arn
}

resource "aws_iam_policy" "sns" {
  name        = "${var.owner}-sns-policy"
  description = "A policy to use with lambda function"
  policy      = data.aws_iam_policy_document.sns.json
}


resource "aws_iam_policy" "s3_put_object" {
  name        = "${var.owner}-s3-policy-put-object"
  description = "A policy to use with lambda function"
  policy      = data.aws_iam_policy_document.s3_put_object.json
}

resource "aws_iam_policy" "dynamodb_put_item" {
  name   = "${var.owner}-dynamodb-put-item"
  policy = data.aws_iam_policy_document.dynamodb_put_item.json
}

resource "aws_iam_policy" "sqs_send_msg" {
  name   = "${var.owner}-sqs-policy-send-msg"
  policy = data.aws_iam_policy_document.sqs_send_msg.json
}
