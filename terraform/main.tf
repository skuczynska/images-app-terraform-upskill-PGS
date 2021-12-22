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
}

module "dynamodb" {
  source = "./dynamodb"
}

module "dynamodb" {
  source = "./dynamodb"
}

module "lambdas" {
  source = "./lambda"
}

module "queue" {
  source = "./queue"
}

module "sns" {
  source = "./sns"
}