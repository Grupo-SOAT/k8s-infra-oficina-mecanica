variable "repository_name" {
  type        = string
  description = "Nome do repositorio ECR"
}

variable "image_tag_mutability" {
  type        = string
  description = "Mutabilidade das tags (MUTABLE ou IMMUTABLE)"
  default     = "MUTABLE"
}

variable "scan_on_push" {
  type        = bool
  description = "Habilitar varredura de vulnerabilidades ao fazer push"
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Tags para os recursos"
  default     = {}
}
