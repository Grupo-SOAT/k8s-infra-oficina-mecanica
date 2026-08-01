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