terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = var.region
}

data "archive_file" "lambda-POST-presignedURL-zip" {
  type        = "zip"
  source_file = "src/lambda_POST_presignedURL.py"
  output_path = "lambda-POST-presignedURL.zip"
}


resource "aws_iam_role" "skuczynska-lambda-iam" {
  name               = "skuczynska-lambda-iam"
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

resource "aws_lambda_function" "skuczynska-lambda-POST_presignedURL" {
  filename         = "lambda-POST-presignedURL.zip"
  function_name    = "skuczynska-lambda-POST_presignedURL"
  role             = aws_iam_role.skuczynska-lambda-iam.arn
  handler          = "lambda.lambda_handler"
  source_code_hash = data.archive_file.lambda-POST-presignedURL-zip.output_base64sha256
  runtime          = "python3.8"
}

#data "aws_availability_zones" "azs" {}

#module "vpc" {
#  source = "terraform-aws-modules/vpc/aws"
#
#  name = "skuczynska-vpc"
#  cidr = var.vpc_cidr_range
#
#  azs = slice(data.aws_availability_zones.azs.names, 0, 2)
#  public_subnets = var.public_subnets
#
#  enable_vpn_gateway = true
#
#  # Database subnets
#  database_subnets = var.database_subnets
#  database_subnet_group_tags ={
#    subnet_type = "database"
#  }
#
#  tags = {
#    Environment = "dev"
#  }
#}
#
#resource "aws_s3_bucket" "skuczynska-bucket" {
#  bucket = "skuczynska-bucket"
#  acl    = "private"
#
#  tags = {
#    Name        = "skuczynska-bucket"
#    Environment = "dev"
#  }
#}
#
#resource "aws_iam_group" "skuczynska-bucket_full_access" {
#  name = "skuczynska-bucket-full-access"
#}
#
#resource "aws_api_gateway_rest_api" "skuczynska-images-API" {
#  name        = "skuczynska-images-API"
#  description = "This is my API for an images modyfication app"
#}

#resource "aws_iam_role" "iam_for_lambda_POST_presigned_URL" {
#  name = "iam_for_lambda_POST_presigned_URL"
#
#  assume_role_policy = <<EOF
#{
#  "Version": "2012-10-17",
#  "Statement": [
#    {
#      "Action": "sts:AssumeRole",
#      "Principal": {
#        "Service": "lambda.amazonaws.com"
#      },
#      "Effect": "Allow",
#      "Sid": ""
#    }
#  ]
#}
#EOF
#}
#
#resource "aws_lambda_function" "skuczynska-POST-presigned-URL" {
#  filename      = "lambda_function_payload.zip"
#  function_name = "skuczynska-POST-presigned-URL"
#  role          = aws_iam_role.iam_for_lambda_POST_presigned_URL.arn
#  handler       = "index.test"
#
#  # The filebase64sha256() function is available in Terraform 0.11.12 and later
#  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
#  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
#  source_code_hash = filebase64sha256("lambda_function_payload.zip")
#
#  runtime = "nodejs12.x"
#
#  environment {
#    variables = {
#      foo = "bar"
#    }
#  }
#}