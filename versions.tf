terraform {

  required_version = ">= 1.11"

  required_providers {

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.38"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14"
    }

    aws = {

      source = "hashicorp/aws"

      version = "~> 5.0"

    }

  }

}