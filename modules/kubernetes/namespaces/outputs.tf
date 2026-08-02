output "namespaces" {
  value = [
    for ns in kubernetes_namespace.criando_namespaces :
    ns.metadata[0].name
  ]
}