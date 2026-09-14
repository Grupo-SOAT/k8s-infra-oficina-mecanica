output "api_endpoint" {
  description = "Endpoint público (domínio) da API Gateway de teste"
  value       = module.gateway_under_test.api_endpoint
}

output "routes" {
  description = "Rotas configuradas no gateway de teste (vazio enquanto não houver Lambda integrada)"
  value       = module.gateway_under_test.routes
}

output "mock_url" {
  description = "URL da rota fictícia (HTTP_PROXY para um echo público), pronta para curl"
  value       = "${module.gateway_under_test.api_endpoint}/mock"
}

output "contract_route_keys" {
  description = "Rotas do contrato real (openapi/) criadas neste teste"
  value       = local.contract_route_keys
}

output "sample_contract_urls" {
  description = "Algumas URLs do contrato real, sem path params, prontas para curl"
  value = [
    "${module.gateway_under_test.api_endpoint}/api/v1/owners",
    "${module.gateway_under_test.api_endpoint}/api/v1/service-orders",
    "${module.gateway_under_test.api_endpoint}/api/v1/reports/catalog/services/average-time",
  ]
}
