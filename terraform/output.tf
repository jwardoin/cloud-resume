output "api_url" {
  value = aws_api_gateway_deployment.CRC_API_deploy.invoke_url
}

output "api_arn" {
  value = aws_lambda_permission.allow_api.source_arn
}
