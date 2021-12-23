terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

module "api" {
  source = "./api"

  presigned_url_arn = module.lambdas.presigned_url_arn
}

module "bucket" {
  source = "./bucket"

  resize_arn = module.lambdas.resize_arn
  allow_bucket_permission = module.lambdas.allow_bucket_permission
}

module "dynamodb" {
  source = "./dynamodb"
}

module "lambdas" {
  source = "./lambda"

  bucket_resized_arn = module.bucket.bucket_resized_arn
  api_arn = module.api.api_arn
}

module "queue" {
  source = "./queue"

  sqs_to_dynamo_arn = module.lambdas.sqs_to_dynamo_arn
}

module "sns" {
  source = "./sns"
}