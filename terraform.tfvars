cluster_name     = "oficina-mecanica-cluster"
namespace_app    = "oficina-mecanica"
namespace_argocd = "argocd"
aws_region = "us-east-1"
bucket_name_kafka = "oficina-mecanica-kafka-history"
ecr_repository_name_mnl = "registry-oficina-mecanica-mnl"
ecr_repository_name_ms_orcamentos = "registry-oficina-mecanica-ms-orcamentos"
image_tag_mutability = "MUTABLE"
ecr_scan_on_push = true
default_tags = {"ManagedBy" = "terraform"}