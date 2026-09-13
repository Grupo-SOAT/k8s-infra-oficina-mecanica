data "aws_caller_identity" "current" {}

locals {
  # AWS Academy recria a conta a cada reset de sessão do lab, então não dá
  # pra fixar o account id da LabRole: resolve pela conta autenticada no momento.
  aws_lab_role_arn = var.aws_lab_role_arn != "" ? var.aws_lab_role_arn : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/voclabs/LabRole"
}

module "lambda_under_test" {
  source = "../../lambda"

  function_name = var.function_name

  project_name = var.project_name

  aws_lab_role_arn = local.aws_lab_role_arn

  runtime = var.runtime

  handler = var.handler

  lambda_s3_bucket = var.lambda_s3_bucket

  lambda_s3_key = var.lambda_s3_key

  source_code_hash = var.source_code_hash

  timeout = var.timeout

  memory_size = var.memory_size

  database_user_secret_arn = var.database_user_secret_arn

  database_password_secret_arn = var.database_password_secret_arn

  database_host = var.database_host

  database_port = var.database_port

  database_name = var.database_name

  jwt_secret_arn = var.jwt_secret_arn

  backend_url = var.backend_url
}

module "gateway_under_test" {
  source = "../"

  api_name = var.api_name

  project_name = var.project_name

  lambda_function_name = module.lambda_under_test.function_name

  lambda_arn = module.lambda_under_test.function_arn

  resources = var.resources
}
