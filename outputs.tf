output "namespace_app" {
  value = kubernetes_namespace.oficina.metadata[0].name
}

output "namespace_argocd" {
  value = kubernetes_namespace.argocd.metadata[0].name
}