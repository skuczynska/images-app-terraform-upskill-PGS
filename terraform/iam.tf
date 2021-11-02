# Role
resource "aws_iam_role" "skuczynska-role-presigned-url" {
  name               = "skuczynska-role-presigned-url"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
  managed_policy_arns = [
    aws_iam_policy.s3_put_object.arn,
    data.aws_iam_policy.cloudwatch_full_access.arn,
  ]
}

#policies
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

#resource "aws_iam_role" "skuczynska-lambda-role" {
#  name               = "skuczynska-lambda-role"
#  assume_role_policy = <<EOF
#{
#  "Version": "2012-10-17",
#  "Statement": [
#    {
#      "Action": "sts:AssumeRole",
#      "Principal": {
#        "Service": "lambda.amazonaws.com"
#        },
#      "Effect": "Allow",
#      "Sid": ""
#    }
#  ]
#}
#
#EOF
#}
#
## Policies
#resource "aws_iam_role_policy" "skuczynska-api-gateway-policy" {
#  name       = "skuczynska-api-gateway-policy"
#  role       = aws_iam_role.skuczynska-lambda-role.id
#  depends_on = [aws_iam_role.skuczynska-lambda-role]
#  policy = jsonencode({
#    "Version" : "2012-10-17",
#    "Statement" : [
#      {
#        "Effect" : "Allow",
#        "Action" : [
#          "execute-api:Invoke",
#          "execute-api:ManageConnections"
#        ],
#        "Resource" : "arn:aws:execute-api:*:*:*"
#      }
#    ]
#  })
#}
#
#resource "aws_iam_role_policy" "skuczynska-sqs-policy" {
#  name       = "skuczynska-sqs-policy"
#  role       = aws_iam_role.skuczynska-lambda-role.id
#  depends_on = [aws_iam_role.skuczynska-lambda-role]
#  policy = jsonencode({
#    "Version" : "2012-10-17",
#    "Statement" : [
#      {
#        "Action" : [
#          "sqs:*"
#        ],
#        "Effect" : "Allow",
#        "Resource" : "*"
#      }
#    ]
#  })
#}
#
#resource "aws_iam_role_policy" "skuczynska-bucket-policy" {
#  name       = "skuczynska-bucket-policy"
#  role       = aws_iam_role.skuczynska-lambda-role.id
#  depends_on = [aws_iam_role.skuczynska-lambda-role]
#  policy = jsonencode({
#    "Version" : "2012-10-17",
#    "Statement" : [
#      {
#        "Effect" : "Allow",
#        "Action" : [
#          "s3:*",
#          "s3-object-lambda:*"
#        ],
#        "Resource" : "*"
#      }
#    ]
#  })
#}
#
#resource "aws_iam_role_policy" "skuczynska-cloudwatch-policy" {
#  name       = "skuczynska-cloudwatch-policy"
#  role       = aws_iam_role.skuczynska-lambda-role.id
#  depends_on = [aws_iam_role.skuczynska-lambda-role]
#  policy = jsonencode({
#    "Version" : "2012-10-17",
#    "Statement" : [
#      {
#        "Action" : [
#          "logs:*"
#        ],
#        "Effect" : "Allow",
#        "Resource" : "*"
#      }
#    ]
#  })
#}
#
## Cloudwatch group
#resource "aws_cloudwatch_log_group" "skuczynska-lambda-POST_presignedURL" {
#  name       = "/aws/lambda/skuczynska-lambda-POST_presignedURL"
#  depends_on = [aws_lambda_function.skuczynska-lambda-POST_presignedURL]
#}