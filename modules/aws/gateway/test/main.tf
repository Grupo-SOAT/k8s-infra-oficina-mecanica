data "aws_lambda_function" "validator" {
  function_name = var.lambda_function_name
}

module "gateway_under_test" {
  source = "../"

  api_name = var.api_name

  project_name = var.project_name

  lambda_function_name = data.aws_lambda_function.validator.function_name

  lambda_arn = data.aws_lambda_function.validator.arn

  resources = var.resources

  # statement_id distinto do usado pela API Gateway de produção (main.tf da raiz),
  # já que as duas apontam para a mesma Lambda "oficina-mecanica-validator".
  permission_statement_id = "AllowApiGatewayInvokeGatewayTest"
}
