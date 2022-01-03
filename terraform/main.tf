terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
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
  source = "./lambda_api"

  bucket_resized_arn = module.bucket.bucket_resized_arn
}

module "queue" {
  source = "./queue"

  sqs_to_dynamo_arn = module.lambdas.sqs_to_dynamo_arn
}

module "sns" {
  source = "./sns"
}