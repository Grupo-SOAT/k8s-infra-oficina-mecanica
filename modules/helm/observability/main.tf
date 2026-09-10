resource "helm_release" "kps" {
  name       = "kps"
  namespace  = var.namespace
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "88.6.1"
  timeout    = 900

  values = [file("${path.root}/k8s/observability/helm/kps-values.yaml")]
}

resource "helm_release" "loki" {
  name       = "loki"
  namespace  = var.namespace
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki"
  version    = "7.3.0"
  timeout    = 600

  values = [file("${path.root}/k8s/observability/helm/loki-values.yaml")]
}

resource "helm_release" "tempo" {
  name       = "tempo"
  namespace  = var.namespace
  repository = "https://grafana.github.io/helm-charts"
  chart      = "tempo"
  version    = "1.24.4"
  timeout    = 600

  values = [file("${path.root}/k8s/observability/helm/tempo-values.yaml")]
}

resource "helm_release" "alloy" {
  name       = "alloy"
  namespace  = var.namespace
  repository = "https://grafana.github.io/helm-charts"
  chart      = "alloy"
  version    = "1.12.1"
  timeout    = 600

  depends_on = [helm_release.kps]

  values = [file("${path.root}/k8s/observability/helm/alloy-values.yaml")]
}
