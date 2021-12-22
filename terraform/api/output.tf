output "base_url" {
  value = aws_api_gateway_deployment.deployment.invoke_url
}

output "api_arn" {
  value = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}