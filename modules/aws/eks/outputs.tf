output "cluster_name" {
  value       = aws_eks_cluster.this.name
  description = "Nome do cluster EKS criado"
}

output "cluster_endpoint" {
  value       = aws_eks_cluster.this.endpoint
  description = "Endpoint do cluster para interacao com o kubectl"
}

output "cluster_certificate_authority_data" {
  value       = aws_eks_cluster.this.certificate_authority[0].data
  description = "Dados do certificado CA para configuracao do kubeconfig"
}

output "cluster_oidc_issuer_url" {
  value       = aws_eks_cluster.this.identity[0].oidc[0].issuer
  description = "URL do provedor OIDC do cluster (Util para mapear IAM Roles para ServiceAccounts)"
}

output "cluster_arn" {

 value = aws_eks_cluster.this.arn

}

output "node_group_name" {

 value = aws_eks_node_group.this.node_group_name

}

