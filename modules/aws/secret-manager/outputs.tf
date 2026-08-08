output "secret_id" {
  description = "ID da secret"
  value       = aws_secretsmanager_secret.this.id
}

output "secret_arn" {
  description = "ARN da secret"
  value       = aws_secretsmanager_secret.this.arn
}

output "secret_name" {
  description = "Nome da secret"
  value       = aws_secretsmanager_secret.this.name
}