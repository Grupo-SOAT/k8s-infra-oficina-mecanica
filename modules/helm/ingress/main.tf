resource "helm_release" "ingress_nginx" {
  name = "ingress-nginx"

  repository = "https://kubernetes.github.io/ingress-nginx"

  chart = "ingress-nginx"

  namespace = "ingress-nginx"

  create_namespace = true

  timeout = 600

  set = [
    {
      name  = "controller.service.type"
      value = "NodePort"
    },
		{
			name  = "controller.service.nodePorts.http"
			value = "30080"
		},
		{
			name  = "controller.service.nodePorts.https"
			value = "30443"
		}
  ]
}