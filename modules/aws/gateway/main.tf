resource "aws_apigatewayv2_api" "this" {
  name          = var.api_name
  protocol_type = "HTTP"

  tags = {
    ManagedBy = "Terraform"
    Project   = var.project_name
  }
}


resource "aws_apigatewayv2_integration" "lambda" {
  api_id = aws_apigatewayv2_api.this.id

  integration_type   = "AWS_PROXY"
  integration_uri    = var.lambda_arn
  integration_method = "POST"

  payload_format_version = "2.0"
}


locals {
  # Para cada recurso do contrato, expõe a rota "de coleção" (ex: /clientes)
  # e a rota "de subcaminho" (ex: /clientes/{proxy+}, cobre /clientes/123 etc).
  route_keys = toset(flatten([
    for resource in var.resources : [
      "ANY /${resource}",
      "ANY /${resource}/{proxy+}",
    ]
  ]))
}

resource "aws_apigatewayv2_route" "this" {
  for_each = local.route_keys

  api_id = aws_apigatewayv2_api.this.id

  route_key = each.value

  target = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}


resource "aws_apigatewayv2_stage" "default" {
  api_id = aws_apigatewayv2_api.this.id

  name = "$default"

  auto_deploy = true

  default_route_settings {
    throttling_rate_limit  = var.throttling_rate_limit
    throttling_burst_limit = var.throttling_burst_limit
  }

  tags = {
    ManagedBy = "Terraform"
    Project   = var.project_name
  }
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id = var.permission_statement_id

  action = "lambda:InvokeFunction"

  function_name = var.lambda_function_name

  principal = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.this.execution_arn}/*/*"
}
