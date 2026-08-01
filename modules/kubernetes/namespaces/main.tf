resource "kubernetes_namespace" "criando_namespaces" {
  for_each = toset(var.namespaces)

  metadata {
    name = each.value
  }
}