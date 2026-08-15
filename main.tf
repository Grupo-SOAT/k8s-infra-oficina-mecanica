module "namespaces" {
  source = "./modules/kubernetes/namespaces"

  depends_on = [
    module.eks
  ]

  namespaces = [ 
    var.namespace_app,
    var.namespace_argocd
  ]
}

module "metrics_server" {
  source = "./modules/helm/metrics-server"

  depends_on = [
    module.eks
  ]
}


module "aws_load_balancer_controller" {
  source = "./modules/helm/aws-load-balancer"

  depends_on = [
    module.eks
  ]

  cluster_name = module.eks.cluster_name
  aws_region   = var.aws_region
  vpc_id       = module.eks.vpc_id
}

module "argocd" {
  source = "./modules/argocd"

  depends_on = [
    module.namespaces
  ]

	namespace = var.namespace_argocd
  app_namespace   = var.namespace_app

  repo_url        = var.git_repo_url
  target_revision_branch = var.git_target_revision_branch
  manifests_path       = var.git_manifests_path
}

module "s3_kafka_storage" {

  source = "./modules/aws/s3"


  bucket_name = var.bucket_name_kafka

}

module "s3_lambda_code" {
  source = "./modules/aws/s3"

  bucket_name = var.bucket_name_lambda
}

module "ecr_registry_mnl" {

    source = "./modules/aws/ecr"

    repository_name = var.ecr_repository_name_mnl

    image_tag_mutability = var.image_tag_mutability

    scan_on_push = var.ecr_scan_on_push

    tags = var.default_tags

}

module "ecr_registry_ms_orcamentos" {

    source = "./modules/aws/ecr"

    repository_name = var.ecr_repository_name_ms_orcamentos

    image_tag_mutability = var.image_tag_mutability

    scan_on_push = var.ecr_scan_on_push

    tags = var.default_tags

}

module "network" {

  source = "./modules/aws/network"

}

module "eks" {

  source = "./modules/aws/eks"

  subnet_ids = module.network.subnet_ids

  aws_academy_role_arn = var.aws_lab_role

  cluster_name = var.cluster_name

}

module "database_user_secret" {
  source = "./modules/aws/secret-manager"

  secret_name  = "oficina-mecanica/database-user"
  description  = "Credencial de usuário do banco de dados"
  project_name = var.project_name

  secret_value = var.database_user_secret
}

module "database_password_secret" {
  source = "./modules/aws/secret-manager"

  secret_name  = "oficina-mecanica/database-password"
  description  = "Credencial de senha do banco de dados"
  project_name = var.project_name

  secret_value = var.database_password_secret
}

module "jwt_secret" {
  source = "./modules/aws/secret-manager"

  secret_name  = "oficina-mecanica/jwt-secret"
  description  = "Secret para validar assinatura jwt"
  project_name = var.project_name

  secret_value = var.jwt_secret
}

module "api_key_chatbot" {
  source = "./modules/aws/secret-manager"

  secret_name  = "oficina-mecanica/api-key-chatbot"
  description  = "chave para o CHATBOT acessar a API"
  project_name = var.project_name

  secret_value = var.api_key_chatbot
}

module "spring_datasource_password" {
  source = "./modules/aws/secret-manager"

  secret_name  = "oficina-mecanica/spring-datasource-password"
  description  = "Senha do spring datasource"
  project_name = var.project_name

  secret_value = var.spring_datasource_password
}

module "spring_datasource_username" {
  source = "./modules/aws/secret-manager"

  secret_name  = "oficina-mecanica/spring-datasource-username"
  description  = "usuario spring datasource"
  project_name = var.project_name

  secret_value = var.spring_datasource_username
}

module "default_user_password" {
  source = "./modules/aws/secret-manager"

  secret_name  = "oficina-mecanica/default-user-password"
  description  = "Senha default para todo usuario criado no sistema"
  project_name = var.project_name

  secret_value = var.default_user_password
}

module "api_gateway" {
  source = "./modules/aws/gateway"

  api_name = "oficina-mecanica-api"

  project_name = var.project_name

  lambda_function_name = module.lambda.function_name

  lambda_arn = module.lambda.function_arn

}

module "lambda" {

  depends_on = [
    module.s3_lambda_code
  ]

  source = "./modules/aws/lambda"

  function_name = "oficina-mecanica-validator"

  project_name = var.project_name

  aws_lab_role_arn = var.aws_lab_role

  runtime = "java21"

  handler = "br.com.oficina.lambda.ValidatorHandler::handleRequest"

  lambda_s3_bucket = var.bucket_name_lambda

  lambda_s3_key    = "oficina-mecanica-validator.zip"

  source_code_hash = var.source_hash_code_lambda

  database_user_secret_arn = module.database_user_secret.secret_arn

  database_password_secret_arn = module.database_password_secret.secret_arn

  backend_url = var.backend_url
}