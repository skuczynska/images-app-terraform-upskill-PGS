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
  name               = "${var.owner}-presigned-url"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
  managed_policy_arns = [
    aws_iam_policy.s3_put_object.arn,
    data.aws_iam_policy.cloudwatch_full_access.arn,
  ]
}

data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "s3_put_object" {
  name        = "${var.owner}-s3-policy-put-object"
  description = "A policy to use with lambda function"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*Object*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

