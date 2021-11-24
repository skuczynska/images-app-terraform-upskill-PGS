resource "aws_cloudwatch_log_group" "cloudwatch_group_resize" {
  name = "/aws/lambda/${var.owner}-lambda-resize"
}