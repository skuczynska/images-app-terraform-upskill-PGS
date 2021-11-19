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
  region  = "eu-central-1"
}


resource "aws_dynamodb_table" "images-dynamodb-table" {
  name           = "skuczynska-images-dynamodb"
  hash_key       = "Image name"
  write_capacity = 20
  read_capacity  = 20

  attribute {
    name = "Image name"
    type = "S"
  }
}