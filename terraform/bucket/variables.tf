variable "owner" {
  type = string
  default = "skuczynska"
}

variable "bucket_folder_name" {
  type    = string
  default = "images/"
}

variable "bucket_tmp_name" {
  type    = string
  default = "tmp/"
}

variable "resize_arn" {
  type = string
}

variable "allow_bucket_permission" {
  type = string
}