module "namespaces" {
  source = "./modules/kubernetes/namespaces"

  depends_on = [
    module.eks
  ]

  namespaces = [ 
    var.namespace_app,
    var.namespace_argocd
  ]
}

module "metrics_server" {
  source = "./modules/helm/metrics-server"

  depends_on = [
    module.eks
  ]
}


module "aws_load_balancer_controller" {
  source = "./modules/kubernetes/aws-load-balancer-controller"

  depends_on = [
    module.eks
  ]

  cluster_name = module.eks.cluster_name
  aws_region   = var.aws_region
  vpc_id       = module.eks.vpc_id
}

module "argocd" {
  source = "./modules/argocd"

  depends_on = [
    module.namespaces
  ]

	namespace = var.namespace_argocd
  app_namespace   = var.namespace_app

  repo_url        = var.git_repo_url
  target_revision_branch = var.git_target_revision_branch
  manifests_path       = var.git_manifests_path
}

module "s3_kafka_storage" {

  source = "./modules/aws/s3"


  bucket_name = var.bucket_name_kafka

}

module "ecr_registry_mnl" {

    source = "./modules/aws/ecr"

    repository_name = var.ecr_repository_name_mnl

    image_tag_mutability = var.image_tag_mutability

    scan_on_push = var.ecr_scan_on_push

    tags = var.default_tags

}

module "ecr_registry_ms_orcamentos" {

    source = "./modules/aws/ecr"

    repository_name = var.ecr_repository_name_ms_orcamentos

    image_tag_mutability = var.image_tag_mutability

    scan_on_push = var.ecr_scan_on_push

    tags = var.default_tags

}

module "network" {

  source = "./modules/aws/network"

}

module "eks" {

  source = "./modules/aws/eks"

  subnet_ids = module.network.subnet_ids

  aws_academy_role_arn = var.aws_lab_role

  cluster_name = var.cluster_name

}