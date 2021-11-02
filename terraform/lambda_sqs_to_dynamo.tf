resource "aws_lambda_function" "sqs_to_dynamo" {
  filename         = "lambda_to_dynamo_payload.zip"
  function_name    = "skuczynska-lambda_to_dynamo_payload-zip"
  role             = aws_iam_role.role_sqs_to_dynamo.arn
  handler          = "lambda_to_dynamo_payload.lambda_handler"
  source_code_hash = data.archive_file.lambda_to_dynamo_payload-zip.output_base64sha256

  runtime = "python3.8"
}
