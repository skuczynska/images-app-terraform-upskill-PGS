# SNS
resource "aws_sns_topic" "topic" {
  name = "s3-event-notification-topic"
}

resource "aws_sns_topic_subscription" "sns-subscription" {
  topic_arn = aws_sns_topic.topic.arn
  protocol  = var.protocol
  endpoint  = var.email
}