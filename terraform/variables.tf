variable "owner" {
  type = string
  default = "skuczynska"
}

variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "account_id" {
  type    = string
  default = "890769921003"
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

variable "email" {
  type    = string
  default = "skuczynska@pgs-soft.com"
}

variable "protocol" {
  default     = "email"
  description = "SNS Protocol to use. email or email-json"
  type        = string
}