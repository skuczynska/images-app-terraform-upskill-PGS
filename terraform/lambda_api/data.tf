data "archive_file" "presigned_url" {
  type        = "zip"
  source_file = "${path.module}/../lambda_functions/lambda_presigned_url.py"
  output_path = "presigned_url.zip"
}

data "archive_file" "modyf_image" {
  type        = "zip"
  source_file = "${path.module}/../lambda_functions/lambda_modyf_image.py"
  output_path = "modyf_image.zip"
}

data "archive_file" "to_dynamo" {
  type        = "zip"
  source_file = "${path.module}/../lambda_functions/lambda_to_dynamo_payload.py"
  output_path = "to_dynamo.zip"
}

data "aws_iam_policy" "cloudwatch_full_access" {
  arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}


data "aws_iam_policy_document" "lambda_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "s3_put_object" {
  statement {
    actions   = ["s3:*Object*"]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "sns" {
  statement {
    actions   = ["sns:*"]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "dynamodb_put_item" {
  statement {
    actions   = ["dynamodb:PutItem"]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "sqs_send_msg" {
  statement {
    actions   = ["sqs:*"]
    resources = ["*"]
  }
}

data "aws_iam_policy" "sqs_full_access" {
  arn = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
}

