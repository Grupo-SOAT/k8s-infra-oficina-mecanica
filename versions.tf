terraform {

  required_version = ">= 1.11"

  required_providers {

    minikube = {
      source  = "scott-the-programmer/minikube"
      version = "~> 0.6"
    }

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

  }

}