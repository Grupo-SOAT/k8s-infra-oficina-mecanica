output "api_endpoint" {
  description = "Endpoint público da API Gateway de teste"
  value       = module.gateway_under_test.api_endpoint
}

output "test_url" {
  description = "URL pronta para curl, usando o primeiro recurso da lista de teste"
  value       = "${module.gateway_under_test.api_endpoint}/${var.resources[0]}"
}

output "routes" {
  description = "Rotas configuradas no gateway de teste"
  value       = module.gateway_under_test.routes
}

output "dummy_lambda_name" {
  description = "Nome do Lambda dummy criado só para este teste"
  value       = aws_lambda_function.dummy.function_name
}
