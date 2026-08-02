resource "helm_release" "argocd" {
  name = "argocd"

  repository = "https://argoproj.github.io/argo-helm"

  chart = "argo-cd"

  timeout = 600

  namespace = var.namespace
}

resource "kubectl_manifest" "application" {

  depends_on = [
    helm_release.argocd
  ]

  yaml_body = templatefile(
    "${path.module}/application.yaml.tftpl",
    {
      argocd_namespace = var.namespace
      app_namespace    = var.app_namespace
      repo_url         = var.repo_url
      target_revision_branch  = var.target_revision_branch
      manifests_path         = var.manifests_path
    }
  )
}