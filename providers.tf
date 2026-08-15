provider "aws" {

  region = var.aws_region

}

provider "kubernetes" {

  host                   = module.eks.cluster_endpoint

  client_certificate     = module.eks.cluster_certificate_authority_data

  cluster_ca_certificate = module.eks.cluster_certificate_authority_data

}

provider "helm" {

  kubernetes = {

    host                   = module.eks.cluster_endpoint

    client_certificate     = module.eks.cluster_certificate_authority_data

    cluster_ca_certificate = module.eks.cluster_certificate_authority_data

  }

}

provider "kubectl" {
  host                   = module.eks.cluster_endpoint
  client_certificate     = module.eks.cluster_certificate_authority_data
  cluster_ca_certificate = module.eks.cluster_certificate_authority_data
  load_config_file       = false
}
