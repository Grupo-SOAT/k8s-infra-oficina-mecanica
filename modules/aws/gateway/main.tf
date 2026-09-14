resource "aws_apigatewayv2_api" "this" {
  name          = var.api_name
  protocol_type = "HTTP"

  tags = {
    ManagedBy = "Terraform"
    Project   = var.project_name
  }
}

# ---------------------------------------------------------------------------
# Auth:
# POST /auth/cpf é direcionado para a Lambda validator.
# Ela é responsável por validar o CPF e emitir o JWT.
# ---------------------------------------------------------------------------

resource "aws_apigatewayv2_integration" "lambda" {
  api_id = aws_apigatewayv2_api.this.id

  integration_type   = "AWS_PROXY"
  integration_uri    = var.lambda_arn
  integration_method = "POST"

  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "auth" {
  api_id = aws_apigatewayv2_api.this.id

  route_key = "POST /${var.auth_resource}/cpf"

  target = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_lambda_permission" "api_gateway_validator" {
  statement_id = "AllowApiGatewayInvokeValidator"

  action = "lambda:InvokeFunction"

  function_name = var.lambda_function_name

  principal = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.this.execution_arn}/*/*"
}

# ---------------------------------------------------------------------------
# Authorizer:
# Valida o JWT emitido pela Lambda nas rotas de negócio.
# ---------------------------------------------------------------------------

resource "aws_apigatewayv2_authorizer" "jwt" {
  api_id = aws_apigatewayv2_api.this.id
  name   = "${var.project_name}-jwt-authorizer"

  authorizer_type = "REQUEST"
  authorizer_uri  = var.authorizer_invoke_arn

  authorizer_payload_format_version = "2.0"
  enable_simple_responses           = true

  identity_sources = ["$request.header.Authorization"]

  authorizer_result_ttl_in_seconds = var.authorizer_result_ttl_in_seconds
}

resource "aws_lambda_permission" "api_gateway_authorizer" {
  statement_id = "AllowApiGatewayInvokeAuthorizer"

  action = "lambda:InvokeFunction"

  function_name = var.authorizer_function_name

  principal = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.this.execution_arn}/authorizers/${aws_apigatewayv2_authorizer.jwt.id}"
}

# ---------------------------------------------------------------------------
# Rotas de negócio:
# São encaminhadas diretamente para o backend via HTTP_PROXY,
# sem passar pela Lambda validator.
#
# Existem duas integrações por recurso:
#
# 1. backend_flat:
#    /clientes
#
# 2. backend_proxy:
#    /clientes/{proxy+}
#
# A segunda utiliza overwrite:path para preservar o caminho completo
# recebido pelo API Gateway.
# ---------------------------------------------------------------------------

resource "aws_apigatewayv2_integration" "backend_flat" {
  for_each = toset(var.resources)

  api_id = aws_apigatewayv2_api.this.id

  integration_type   = "HTTP_PROXY"
  integration_method = "ANY"
  integration_uri    = "${var.backend_url}/${each.value}"

  payload_format_version = "1.0"
}

resource "aws_apigatewayv2_integration" "backend_proxy" {
  for_each = toset(var.resources)

  api_id = aws_apigatewayv2_api.this.id

  integration_type   = "HTTP_PROXY"
  integration_method = "ANY"
  integration_uri    = var.backend_url

  request_parameters = {
    "overwrite:path" = "$request.path"
  }

  payload_format_version = "1.0"
}

resource "aws_apigatewayv2_route" "protected_flat" {
  for_each = toset(var.resources)

  api_id = aws_apigatewayv2_api.this.id

  route_key = "ANY /${each.value}"

  target = "integrations/${aws_apigatewayv2_integration.backend_flat[each.value].id}"

  authorization_type = "CUSTOM"
  authorizer_id      = aws_apigatewayv2_authorizer.jwt.id
}

resource "aws_apigatewayv2_route" "protected_proxy" {
  for_each = toset(var.resources)

  api_id = aws_apigatewayv2_api.this.id

  route_key = "ANY /${each.value}/{proxy+}"

  target = "integrations/${aws_apigatewayv2_integration.backend_proxy[each.value].id}"

  authorization_type = "CUSTOM"
  authorizer_id      = aws_apigatewayv2_authorizer.jwt.id
}

# ---------------------------------------------------------------------------
# Rotas de autenticação que são tratadas diretamente pelo backend.
# ---------------------------------------------------------------------------

resource "aws_apigatewayv2_integration" "backend_auth" {
  api_id             = aws_apigatewayv2_api.this.id
  integration_type   = "HTTP_PROXY"
  integration_method = "ANY"
  integration_uri    = var.backend_url

  request_parameters = {
    "overwrite:path" = "$request.path"
  }

  payload_format_version = "1.0"
}

resource "aws_apigatewayv2_route" "backend_auth" {
  for_each = toset([
    "POST /auth/login",
    "POST /auth/chatbot",
    "POST /auth/change-password"
  ])

  api_id    = aws_apigatewayv2_api.this.id
  route_key = each.value

  target = "integrations/${aws_apigatewayv2_integration.backend_auth.id}"
}

# ---------------------------------------------------------------------------
# Default stage
# ---------------------------------------------------------------------------

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
