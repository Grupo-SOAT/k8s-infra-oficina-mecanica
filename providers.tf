provider "aws" {

  region = var.aws_region

}

provider "kubernetes" {

  host                   = module.eks.cluster.host

  client_certificate     = module.eks.cluster.client_certificate

  client_key             = module.eks.cluster.client_key

  cluster_ca_certificate = module.eks.cluster.cluster_ca_certificate

}

provider "helm" {

  kubernetes = {

    host                   = module.eks.cluster.host

    client_certificate     = module.eks.cluster.client_certificate

    client_key             = module.eks.cluster.client_key

    cluster_ca_certificate = module.eks.cluster.cluster_ca_certificate

  }

}

provider "kubectl" {
  host                   = module.eks.cluster.host
  client_certificate     = module.eks.cluster.client_certificate
  client_key             = module.eks.cluster.client_key
  cluster_ca_certificate = module.eks.cluster.cluster_ca_certificate
  load_config_file       = false
}
