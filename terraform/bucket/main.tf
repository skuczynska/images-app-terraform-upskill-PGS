resource "aws_s3_bucket" "bucket_resized" {
  bucket        = "${var.owner}-bucket-resized"
  acl           = "public-read"
  force_destroy = true
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = "${var.owner}-bucket-resized"

  lambda_function {
    lambda_function_arn = aws_lambda_function.resize.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}