# Role
resource "aws_iam_role" "role-presigned-url" {
  name               = "${var.owner}-role-presigned-url"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
  managed_policy_arns = [
    aws_iam_policy.s3_put_object.arn,
    data.aws_iam_policy.cloudwatch_full_access.arn,
  ]
}



resource "aws_iam_role" "role_sqs_to_dynamo" {
  name               = "${var.owner}-role_sqs_to_dynamo"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
  managed_policy_arns = [
    aws_iam_policy.dynamodb_put_item.arn,
    data.aws_iam_policy.cloudwatch_full_access.arn,
    data.aws_iam_policy.sqs_full_access.arn
  ]
}

# Policies





# Data
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

data "aws_iam_policy" "sqs_full_access" {
  arn = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
}


