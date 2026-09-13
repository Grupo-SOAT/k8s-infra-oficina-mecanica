data "archive_file" "dummy_lambda" {
  type        = "zip"
  source_file = "${path.module}/fixtures/dummy_handler.py"
  output_path = "${path.module}/.build/dummy_handler.zip"
}

resource "aws_lambda_function" "dummy" {
  function_name = var.dummy_lambda_name

  role = var.aws_lab_role_arn

  runtime = "python3.12"
  handler = "dummy_handler.handler"

  filename         = data.archive_file.dummy_lambda.output_path
  source_code_hash = data.archive_file.dummy_lambda.output_base64sha256

  timeout     = 10
  memory_size = 128

  tags = {
    ManagedBy = "Terraform"
    Project   = var.project_name
    Purpose   = "gateway-test"
  }
}

module "gateway_under_test" {
  source = "../"

  api_name = var.api_name

  project_name = var.project_name

  lambda_function_name = aws_lambda_function.dummy.function_name

  lambda_arn = aws_lambda_function.dummy.arn

  resources = var.resources
}
