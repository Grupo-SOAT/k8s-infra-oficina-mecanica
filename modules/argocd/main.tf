resource "helm_release" "argocd" {
  name = "argocd"

  repository = "https://argoproj.github.io/argo-helm"

  chart = "argo-cd"

  timeout = 600

  cleanup_on_fail = true

  namespace = var.namespace
}

resource "kubectl_manifest" "application" {

  depends_on = [
    helm_release.argocd
  ]

  yaml_body = templatefile(
    "${path.module}/application.yaml.tftpl",
    {
      argocd_namespace       = var.namespace
      app_namespace          = var.app_namespace
      repo_url               = var.repo_url
      target_revision_branch = var.target_revision_branch
      manifests_path         = var.manifests_path
    }
  )
}

resource "kubectl_manifest" "application_observability" {

  depends_on = [
    helm_release.argocd
  ]

  yaml_body = templatefile(
    "${path.module}/application-observability.yaml.tftpl",
    {
      argocd_namespace        = var.namespace
      observability_namespace = var.observability_namespace
      repo_url                = var.repo_url
      target_revision_branch  = var.target_revision_branch
      observability_path      = var.observability_path
    }
  )
}