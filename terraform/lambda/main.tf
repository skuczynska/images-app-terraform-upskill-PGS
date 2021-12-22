resource "aws_lambda_function" "presigned_url" {
  filename         = "presigned_url.zip"
  function_name    = "${var.owner}-presigned-url"
  role             = aws_iam_role.presigned_url.arn
  handler          = "lambda_presigned_url.lambda_handler"
  source_code_hash = data.archive_file.presigned_url.output_base64sha256
  runtime          = "python3.8"

  depends_on = [aws_iam_role.presigned_url]
}

resource "aws_lambda_permission" "presigned_url" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.presigned_url.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
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
  name               = "${var.owner}-role-sqs-to-dynamo"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
  managed_policy_arns = [
    aws_iam_policy.dynamodb_put_item.arn,
    data.aws_iam_policy.cloudwatch_full_access.arn,
    data.aws_iam_policy.sqs_full_access.arn
  ]
}



resource "aws_iam_role" "presigned_url" {
  name               = "${var.owner}-role-presigned-url"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
  managed_policy_arns = [
    aws_iam_policy.s3_put_object.arn,
    data.aws_iam_policy.cloudwatch_full_access.arn,
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
  source_arn    = aws_s3_bucket.bucket_resized.arn
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
