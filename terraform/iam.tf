# Role
resource "aws_iam_role" "skuczynska-role-presigned-url" {
  name               = "skuczynska-role-presigned-url"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
  managed_policy_arns = [
    aws_iam_policy.s3_put_object.arn,
    data.aws_iam_policy.cloudwatch_full_access.arn,
  ]
}

resource "aws_iam_role" "skuczynska-role-rezise" {
  name               = "skuczynska-role-rezise"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
  managed_policy_arns = [
    aws_iam_policy.s3_put_object.arn,
    aws_iam_policy.sqs_send_msg.arn,
    data.aws_iam_policy.cloudwatch_full_access.arn,
    aws_iam_policy.sns_policy.arn
  ]
}

resource "aws_iam_role" "role_sqs_to_dynamo" {
  name               = "skuczynska-role_sqs_to_dynamo"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
  managed_policy_arns = [
    aws_iam_policy.dynamodb_put_item.arn,
    data.aws_iam_policy.cloudwatch_full_access.arn,
    data.aws_iam_policy.sqs_full_access.arn
  ]
}

# Policies
resource "aws_iam_policy" "sns_policy" {
  name        = "skuczynska-sns-policy"
  description = "A policy to use with lambda function"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "sns:*"
            ],
            "Effect": "Allow",
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_policy" "dynamodb_put_item" {
  name = "skuczynska-dynamodb-put-item"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["dynamodb:PutItem"]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_policy" "sqs_send_msg" {
  name   = "skuczynska-sqs-policy-send-msg"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "sqs:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "s3_put_object" {
  name        = "skuczynska-s3-policy-put-object"
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


