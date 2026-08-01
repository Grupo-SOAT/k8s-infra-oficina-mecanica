resource "minikube_cluster" "cluster" {

  driver = "docker"

  cpus = 2

  memory = 6100

  container_runtime = "docker"

}

module "namespaces" {
  source = "./modules/kubernetes/namespaces"

  depends_on = [
    minikube_cluster.cluster
  ]

  namespaces = [ 
    var.namespace_app,
    var.namespace_argocd
  ]
}

module "metrics_server" {
  source = "./modules/helm/metrics-server"
}


module "ingress_nginx" {
  source = "./modules/helm/ingress"
}

module "argocd" {
  source = "./modules/helm/argocd"

  depends_on = [
    module.namespaces
  ]

  namespace = var.namespace_argocd
}

locals {

    manifests_path = "${path.module}/k8s"

}

resource "kubectl_manifest" "configmap" {

    depends_on = [ module.namespaces ]

    yaml_body = file("${local.manifests_path}/configmap.yaml")

}

resource "kubectl_manifest" "secret" {

    depends_on = [ module.namespaces ]

    yaml_body = file("${local.manifests_path}/secret.yaml")

}

resource "kubectl_manifest" "pvc" {

    depends_on = [ module.namespaces ]

    yaml_body = file("${local.manifests_path}/pvc.yaml")

}

resource "kubectl_manifest" "pvc-kafka" {

    depends_on = [ module.namespaces ]

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

    depends_on = [ module.namespaces ]

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

        module.metrics_server,

        kubectl_manifest.deployment-postgres,

        kubectl_manifest.deployment-monolito

    ]

    yaml_body = file("${local.manifests_path}/hpa.yaml")

}

resource "kubectl_manifest" "ingress" {

  depends_on = [
    module.ingress_nginx,
    kubectl_manifest.service-monolito
  ]

  yaml_body = file("${local.manifests_path}/ingress.yaml")
}

module "s3_kafka_storage" {

  source = "./modules/aws/s3"


  bucket_name = var.bucket_name_kafka

}