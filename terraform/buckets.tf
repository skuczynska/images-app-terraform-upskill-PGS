# Bucket
resource "aws_s3_bucket" "skuczynska-bucket-resized" {
  bucket        = "skuczynska-bucket-resized"
  acl           = "private"
  force_destroy = true
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = "skuczynska-bucket-resized"

  lambda_function {
    lambda_function_arn = aws_lambda_function.resize.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}

resource "aws_s3_bucket_object" "object" {
  bucket = aws_s3_bucket.skuczynska-bucket-resized.id
  key    = "tmp/"
}