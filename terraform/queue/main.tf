resource "aws_sqs_queue" "queue" {
  name                      = "${var.owner}-queue"
  delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10
}

resource "aws_lambda_event_source_mapping" "sqs_to_dynamo" {
  event_source_arn = aws_sqs_queue.queue.arn
  function_name    = var.sqs_to_dynamo_arn
}