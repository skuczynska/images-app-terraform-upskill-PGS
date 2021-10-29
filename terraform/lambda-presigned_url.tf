# Lambda
resource "aws_lambda_permission" "skuczynska-lambda-POST-permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.skuczynska-lambda-POST_presignedURL.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.skuczynska-API.execution_arn}/*/*"
}

resource "aws_lambda_function" "skuczynska-lambda-POST_presignedURL" {
  filename         = "lambda-POST-presignedURL.zip"
  function_name    = "skuczynska-lambda-POST_presignedURL"
  role             = aws_iam_role.skuczynska-lambda-role.arn
  handler          = "lambda_POST_presignedURL.lambda_handler"
  source_code_hash = data.archive_file.lambda-POST-presignedURL-zip.output_base64sha256
  runtime          = "python3.8"

  depends_on = [aws_iam_role.skuczynska-lambda-role]
}