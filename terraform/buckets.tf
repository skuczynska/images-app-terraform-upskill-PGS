# Bucket
resource "aws_s3_bucket" "skuczynska-bucket" {
  bucket        = "skuczynska-bucket"
  acl           = "private"
  force_destroy = true

  tags = {
    Name        = "skuczynska-bucket"
    Environment = var.environment
  }
}