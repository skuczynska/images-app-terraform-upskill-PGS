data "archive_file" "presigned_url" {
  type        = "zip"
  source_file = "${path.module}/lambda_functions/lambda_POST_presignedURL.py"
  output_path = "presigned_url.zip"
}

data "archive_file" "modyf_image" {
  type        = "zip"
  source_file = "${path.module}/lambda_functions/lambda_modyf_image.py"
  output_path = "modyf_image.zip"
}

data "archive_file" "lambda_to_dynamo" {
  type        = "zip"
  source_file = "${path.module}/lambda_functions/lambda_to_dynamo_payload.py"
  output_path = "lambda_to_dynamo.zip"
}

data "aws_iam_policy" "cloudwatch_full_access" {
  arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
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