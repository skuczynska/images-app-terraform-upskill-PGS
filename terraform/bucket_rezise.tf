resource "aws_s3_bucket_object" "bucket-obj" {
  bucket     = "skuczynska-bucket"
  key        = "${var.bucket_folder_name}/"
  depends_on = [aws_s3_bucket.skuczynska-bucket]
}

resource "aws_s3_bucket_object" "bucket-obj-tmp" {
  bucket     = "skuczynska-bucket"
  key        = "${var.bucket_tmp_name}/"
  depends_on = [aws_s3_bucket.skuczynska-bucket]
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.skuczynska-bucket.id

  topic {
    topic_arn     = aws_sns_topic.topic.arn
    events        = ["s3:ObjectCreated:*"]
    filter_suffix = ".log"
  }
}