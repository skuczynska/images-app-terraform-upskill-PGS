output "presigned_url_arn" {
  value = aws_lambda_function.presigned_url.invoke_arn
}

output "presigned_url_permission" {
  value = aws_lambda_permission.presigned_url
}

output "resize_arn" {
  value = aws_lambda_function.resize.arn
}

output "sqs_to_dynamo_arn" {
  value = aws_lambda_function.sqs_to_dynamo.arn
}

output "allow_bucket_permission" {
  value = aws_lambda_permission.allow_bucket.source_arn
}

output "base_url" {
  value = aws_api_gateway_deployment.deployment.invoke_url
}
