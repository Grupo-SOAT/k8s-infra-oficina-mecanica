output "api_id" {
  description = "ID da API Gateway"
  value       = aws_apigatewayv2_api.this.id
}

output "api_endpoint" {
  description = "Endpoint público da API"
  value       = aws_apigatewayv2_api.this.api_endpoint
}

output "api_arn" {
  description = "ARN da API Gateway"
  value       = aws_apigatewayv2_api.this.arn
}

output "routes" {
  description = "Rotas configuradas no gateway (contrato exposto), para conferência"
  value       = local.route_keys
}
