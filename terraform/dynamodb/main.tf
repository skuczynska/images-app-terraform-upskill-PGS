resource "aws_dynamodb_table" "images_dynamodb_table" {
  name           = "${var.owner}-images-dynamodb"
  hash_key       = "Image name"
  write_capacity = 20
  read_capacity  = 20

  attribute {
    name = "Image name"
    type = "S"
  }
}