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