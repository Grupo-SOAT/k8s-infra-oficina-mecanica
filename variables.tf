variable "cluster_name" {
  default = "oficina-mecanica-cluster"
}

variable "namespace_app" {
  default = "oficina-mecanica"
}

variable "namespace_argocd" {
  default = "argocd"
}

variable "aws_region" {
  default = "us-east-1"
}

variable "bucket_name_kafka" {
  default = "oficina-mecanica-kafka-history"
}

variable "git_repo_url" {
  default = "https://github.com/Grupo-SOAT/k8s-infra-oficina-mecanica"
}

variable "git_target_revision_branch" {
  default = "main"
}

variable "git_manifests_path" {
  default = "k8s"
}

variable "ecr_repository_name_mnl" {
  default = "registry-oficina-mecanica-mnl"
}

variable "ecr_repository_name_ms_orcamentos" {
  default = "registry-oficina-mecanica-ms-orcamentos"
}

variable "image_tag_mutability" {
  default = "MUTABLE"
}

variable "ecr_scan_on_push" {
  default = true
}

variable "default_tags" {
  default = {"ManagedBy" = "terraform"}
}

variable "aws_lab_role" {
  default = "arn:aws:iam::450853758184:role/voclabs/LabRole"
}

variable "database_user_secret" {
  type        = string
  sensitive   = true
  description = "usuário do banco de dados"
}

variable "database_password_secret" {
  type = string
  sensitive = true
  description = "senha do banco de dados"
}

variable "jwt_secret" {
  type = string
  sensitive = true
  description = "secret para validar assinatura do token jwt"
}

variable "api_key_chatbot" {
  type = string
  sensitive = true
  description = "chave de acesso do BOT para a api"
}

variable "spring_datasource_password" {
  type = string
  sensitive = true
  description = "senha para datasource spring"
}

variable "spring_datasource_username" {
  type = string
  sensitive = true
  description = "usuario para datasource spring"
}

variable "default_user_password" {
  type = string
  sensitive = true
  description = "senha padrao para os usuarios criados"
}

variable "project_name" {
  type = string
  description = "nome do projeto"
}