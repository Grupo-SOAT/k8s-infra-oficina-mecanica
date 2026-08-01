resource "minikube_cluster" "cluster" {

  driver = "docker"

  cpus = 2

  memory = 6100

  container_runtime = "docker"

}


resource "kubernetes_namespace" "oficina" {

  depends_on = [
    minikube_cluster.cluster
  ]

  metadata {
    name = var.namespace_app
  }
}

resource "kubernetes_namespace" "argocd" {

  depends_on = [
    minikube_cluster.cluster
  ]

  metadata {
    name = var.namespace_argocd
  }
}

resource "helm_release" "metrics_server" {
  depends_on = [
    kubernetes_namespace.oficina
  ]

  name       = "metrics-server"
  namespace  = "kube-system"

  repository = "https://kubernetes-sigs.github.io/metrics-server"
  chart      = "metrics-server"

  set = [
    {
      name  = "args[0]"
      value = "--kubelet-insecure-tls"
    }
  ]
}


resource "helm_release" "ingress_nginx" {

  depends_on = [
    kubernetes_namespace.oficina
  ]

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

resource "helm_release" "argocd" {

  depends_on = [
    kubernetes_namespace.argocd
  ]

  name = "argocd"

  repository = "https://argoproj.github.io/argo-helm"

  chart = "argo-cd"

  timeout = 600

  namespace = var.namespace_argocd
}

locals {

    manifests_path = "${path.module}/../k8s"

}

resource "kubectl_manifest" "configmap" {

    depends_on = [ kubernetes_namespace.oficina ]

    yaml_body = file("${local.manifests_path}/configmap.yaml")

}

resource "kubectl_manifest" "secret" {

    depends_on = [ kubernetes_namespace.oficina ]

    yaml_body = file("${local.manifests_path}/secret.yaml")

}

resource "kubectl_manifest" "pvc" {

    depends_on = [ kubernetes_namespace.oficina ]

    yaml_body = file("${local.manifests_path}/pvc.yaml")

}

resource "kubectl_manifest" "pvc-kafka" {

    depends_on = [ kubernetes_namespace.oficina ]

    yaml_body = file("${local.manifests_path}/pvc-kafka.yaml")

}

resource "kubectl_manifest" "deployment-postgres" {

    depends_on = [

        kubectl_manifest.configmap,

        kubectl_manifest.secret,

        kubectl_manifest.pvc

    ]

    yaml_body = file("${local.manifests_path}/deployment-postgres.yaml")

}

resource "kubectl_manifest" "deployment-kafka" {

    depends_on = [

        kubectl_manifest.configmap,

        kubectl_manifest.secret,

        kubectl_manifest.pvc-kafka

    ]

    yaml_body = file("${local.manifests_path}/deployment-kafka.yaml")

}

resource "kubectl_manifest" "deployment-kafka-ui" {

    depends_on = [

        kubectl_manifest.configmap,

        kubectl_manifest.secret,

        kubectl_manifest.pvc-kafka

    ]

    yaml_body = file("${local.manifests_path}/deployment-kafka-ui.yaml")

}

resource "kubectl_manifest" "deployment-monolito" {

    depends_on = [ kubectl_manifest.deployment-postgres, kubectl_manifest.deployment-kafka ]

    yaml_body = file("${local.manifests_path}/deployment-monolito.yaml")

}

resource "kubectl_manifest" "deployment-ms-orcamentos" {

    depends_on = [ kubectl_manifest.deployment-postgres, kubectl_manifest.deployment-kafka, kubectl_manifest.deployment-mailpit ]

    yaml_body = file("${local.manifests_path}/deployment-ms-orcamentos.yaml")

}

resource "kubectl_manifest" "deployment-mailpit" {

    depends_on = [ kubernetes_namespace.oficina ]

    yaml_body = file("${local.manifests_path}/deployment-mailpit.yaml")

}


resource "kubectl_manifest" "service-postgres" {

    depends_on = [ kubectl_manifest.deployment-postgres ]

    yaml_body = file("${local.manifests_path}/service-postgres.yaml")

}

resource "kubectl_manifest" "service-monolito" {

    depends_on = [ kubectl_manifest.deployment-monolito ]

    yaml_body = file("${local.manifests_path}/service-monolito.yaml")

}

resource "kubectl_manifest" "service-kafka" {

    depends_on = [ kubectl_manifest.deployment-kafka ]

    yaml_body = file("${local.manifests_path}/service-kafka.yaml")

}

resource "kubectl_manifest" "service-kafka-ui" {

    depends_on = [ kubectl_manifest.deployment-kafka-ui ]

    yaml_body = file("${local.manifests_path}/service-kafka-ui.yaml")

}

resource "kubectl_manifest" "service-mailpit" {

    depends_on = [ kubectl_manifest.deployment-mailpit ]

    yaml_body = file("${local.manifests_path}/service-mailpit.yaml")

}

resource "kubectl_manifest" "service-ms-orcamentos" {

    depends_on = [ kubectl_manifest.deployment-ms-orcamentos ]

    yaml_body = file("${local.manifests_path}/service-ms-orcamentos.yaml")

}

resource "kubectl_manifest" "hpa" {

    depends_on = [

        helm_release.metrics_server,

        kubectl_manifest.deployment-postgres,

        kubectl_manifest.deployment-monolito

    ]

    yaml_body = file("${local.manifests_path}/hpa.yaml")

}

resource "kubectl_manifest" "ingress" {

  depends_on = [
    helm_release.ingress_nginx,
    kubectl_manifest.service-monolito
  ]

  yaml_body = file("${local.manifests_path}/ingress.yaml")
}
