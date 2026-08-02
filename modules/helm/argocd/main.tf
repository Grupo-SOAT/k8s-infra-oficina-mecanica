resource "helm_release" "argocd" {
  name = "argocd"

  repository = "https://argoproj.github.io/argo-helm"

  chart = "argo-cd"

  timeout = 600

  namespace = var.namespace
}