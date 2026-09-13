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

output "lambda_function_name" {
  description = "Nome da Lambda deste teste (deploy real, mesmo módulo usado pela stack principal)"
  value       = module.lambda_under_test.function_name
}
