# SQS
resource "aws_sqs_queue" "queue" {
  name                        = "skuczynska-queue.fifo"
  fifo_queue                  = true
  content_based_deduplication = true
}

resource "aws_lambda_event_source_mapping" "sqs_to_dynamo" {
  event_source_arn = aws_sqs_queue.queue.arn
  function_name    = aws_lambda_function.sqs_to_dynamo.arn
}