output "repository_url" {
  value       = aws_ecr_repository.this.repository_url
  description = "URL do repositorio ECR"
}

output "repository_arn" {
  value       = aws_ecr_repository.this.arn
  description = "ARN do repositorio ECR"
}
