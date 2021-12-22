resource "aws_s3_bucket" "bucket_resized" {
  bucket        = "${var.owner}-bucket-resized"
  acl           = "public-read"
  force_destroy = true
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = "${var.owner}-bucket-resized"

  lambda_function {
    lambda_function_arn = var.resize_arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [var.allow_bucket_permission]
}