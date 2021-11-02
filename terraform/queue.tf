# Queue
resource "aws_sqs_queue" "skuczynska_queue" {
  name                        = "skuczynska_queue.fifo"
  fifo_queue                  = true
  content_based_deduplication = true
}