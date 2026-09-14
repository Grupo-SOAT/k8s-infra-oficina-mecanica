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

output "db_host" {
  description = "Host do RDS gerenciado (repo db-oficina-mecanica)"
  value       = data.aws_db_instance.this.address
}

output "db_port" {
  description = "Porta do RDS gerenciado"
  value       = data.aws_db_instance.this.port
}

output "db_name" {
  description = "Nome do banco no RDS gerenciado"
  value       = data.aws_db_instance.this.db_name
}