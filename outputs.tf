output "namespaces_criados" {
  value = module.namespaces.namespaces
}

output "cluster_name" {
  description = "Nome do cluster EKS"
  value       = module.eks.cluster_name
}