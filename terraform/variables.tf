variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "account_id" {
  type    = string
  default = "890769921003"
}

variable "vpc_cidr_range" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnets" {
  type    = list(string)
  default = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "database_subnets" {
  type    = list(string)
  default = ["10.0.8.0/24", "10.0.9.0/24"]
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "bucket_folder_name" {
  type    = string
  default = "images/"
}

variable "bucket_tmp_name" {
  type    = string
  default = "tmp/"
}