variable "secret_name" {
  type        = string
  description = "Nome da secret no AWS Secrets Manager"
}

variable "description" {
  type        = string
  description = "Descrição da secret"
  default     = null
}

variable "secret_value" {
  type        = string
  description = "Valor da secret"
  sensitive   = true
}

variable "project_name" {
  type        = string
  description = "Nome do projeto"
}