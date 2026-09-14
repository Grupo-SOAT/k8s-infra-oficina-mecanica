resource "aws_lambda_function" "this" {

  function_name = var.function_name

  role = var.aws_lab_role_arn

  runtime = var.runtime

  handler = var.handler

  s3_bucket = var.lambda_s3_bucket

  s3_key = var.lambda_s3_key

  source_code_hash = var.source_code_hash

  timeout = var.timeout

  memory_size = var.memory_size

  dynamic "vpc_config" {
    for_each = length(var.vpc_subnet_ids) > 0 ? [1] : []

    content {
      subnet_ids         = var.vpc_subnet_ids
      security_group_ids = var.vpc_security_group_ids
    }
  }

  environment {
    variables = {
      DATABASE_HOST     = var.database_host
      DATABASE_PORT     = var.database_port
      DATABASE_NAME     = var.database_name
      DATABASE_USER     = var.database_user
      DATABASE_PASSWORD = var.database_password
      JWT_SECRET        = var.jwt_secret
    }
  }

  # Terraform cria as funcoes; o pipeline lambda-code atualiza o artefato.
  lifecycle {
    ignore_changes = [s3_key, source_code_hash]
  }

  tags = {
    ManagedBy = "Terraform"
    Project   = var.project_name
  }
}
