# Role
resource "aws_iam_role" "skuczynska-presigned-url" {
  name               = "skuczynska-presigned-url"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
        },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}

EOF
}

# Policies
resource "aws_iam_role_policy" "skuczynska-api-gateway-policy" {
  name       = "skuczynska-api-gateway-policy"
  role       = aws_iam_role.skuczynska-lambda-role.id
  depends_on = [aws_iam_role.skuczynska-lambda-role]
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "execute-api:Invoke",
          "execute-api:ManageConnections"
        ],
        "Resource" : "arn:aws:execute-api:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "skuczynska-sqs-policy" {
  name       = "skuczynska-sqs-policy"
  role       = aws_iam_role.skuczynska-lambda-role.id
  depends_on = [aws_iam_role.skuczynska-lambda-role]
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "sqs:*"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "skuczynska-bucket-policy" {
  name       = "skuczynska-bucket-policy"
  role       = aws_iam_role.skuczynska-lambda-role.id
  depends_on = [aws_iam_role.skuczynska-lambda-role]
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:*",
          "s3-object-lambda:*"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "skuczynska-cloudwatch-policy" {
  name       = "skuczynska-cloudwatch-policy"
  role       = aws_iam_role.skuczynska-lambda-role.id
  depends_on = [aws_iam_role.skuczynska-lambda-role]
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "logs:*"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      }
    ]
  })
}

# Cloudwatch group
resource "aws_cloudwatch_log_group" "skuczynska-lambda-POST_presignedURL" {
  name       = "/aws/lambda/skuczynska-lambda-POST_presignedURL"
  depends_on = [aws_lambda_function.skuczynska-lambda-POST_presignedURL]
}