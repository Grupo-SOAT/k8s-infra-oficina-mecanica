output "api_endpoint" {
  description = "Endpoint público (domínio) da API Gateway de teste"
  value       = module.gateway_under_test.api_endpoint
}

output "routes" {
  description = "Rotas configuradas no gateway de teste (vazio enquanto não houver Lambda integrada)"
  value       = module.gateway_under_test.routes
}
