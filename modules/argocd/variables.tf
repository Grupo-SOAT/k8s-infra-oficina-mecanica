variable "namespace" {
  description = "namespace onde o ArgoCD sera criado e instalado"
  type        = string
}

variable "app_namespace" {
  description = "Namespace onde a aplicação será implantada"
  type        = string
}

variable "repo_url" {
  description = "URL do repositório Github contendo os manifests"
  type        = string
}

variable "target_revision_branch" {
  description = "Branch, tag ou commit utilizado pelo ArgoCD"
  type        = string
  default     = "main"
}

variable "manifests_path" {
  description = "Diretório do repositório que contém os manifests"
  type        = string
  default     = "k8s"
}