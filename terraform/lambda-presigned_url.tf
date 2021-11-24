# Lambda

resource "aws_lambda_function" "lambda-POST_presignedURL" {
  filename         = "lambda-POST-presignedURL.zip"
  function_name    = "${var.owner}-lambda-POST_presignedURL"
  role             = aws_iam_role.role-presigned-url.arn
  handler          = "lambda_POST_presignedURL.lambda_handler"
  source_code_hash = data.archive_file.lambda-POST-presignedURL-zip.output_base64sha256
  runtime          = "python3.8"

  depends_on = [aws_iam_role.role-presigned-url]
}

resource "aws_lambda_permission" "lambda-POST-permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda-POST_presignedURL.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.API.execution_arn}/*/*"
}