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

  environment {
    variables = {
      DATABASE_HOST                = var.database_host
      DATABASE_PORT                = var.database_port
      DATABASE_NAME                = var.database_name
      DATABASE_USER_SECRET_ARN     = var.database_user_secret_arn
      DATABASE_PASSWORD_SECRET_ARN = var.database_password_secret_arn
      JWT_SECRET_ARN               = var.jwt_secret_arn
      BACKEND_URL                  = var.backend_url
    }
  }

  tags = {
    ManagedBy = "Terraform"
    Project   = var.project_name
  }
}