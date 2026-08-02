resource "minikube_cluster" "cluster" {

  driver = "docker"

  cpus = 2

  memory = 6100

  container_runtime = "docker"

}

module "namespaces" {
  source = "./modules/kubernetes/namespaces"

  depends_on = [
    minikube_cluster.cluster
  ]

  namespaces = [ 
    var.namespace_app,
    var.namespace_argocd
  ]
}

module "metrics_server" {
  source = "./modules/helm/metrics-server"
}


module "ingress_nginx" {
  source = "./modules/helm/ingress"
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