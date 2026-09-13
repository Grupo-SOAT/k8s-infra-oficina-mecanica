output "namespaces_criados" {
  value = module.namespaces.namespaces
}

output "cluster_name" {
  description = "Nome do cluster EKS"
  value       = module.eks.cluster_name
}

output "api_gateway_endpoint" {
  description = "Endpoint público do API Gateway (entrada para o monólito, validada pela Lambda)"
  value       = module.api_gateway.api_endpoint
}