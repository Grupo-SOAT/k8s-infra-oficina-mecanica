resource "aws_apigatewayv2_api" "this" {
  name          = var.api_name
  protocol_type = "HTTP"

  tags = {
    ManagedBy = "Terraform"
    Project   = var.project_name
  }
}

# ---------------------------------------------------------------------------
# Auth: POST /auth/cpf (e demais subrotas de /auth) sempre na Lambda
# validator - ela e quem valida o CPF e emite o JWT.
# ---------------------------------------------------------------------------

resource "aws_apigatewayv2_integration" "lambda" {
  api_id = aws_apigatewayv2_api.this.id

  integration_type   = "AWS_PROXY"
  integration_uri    = var.lambda_arn
  integration_method = "POST"

  payload_format_version = "2.0"
}

locals {
  auth_route_keys = toset([
    "POST /${var.auth_resource}/cpf",

  ])
}

resource "aws_apigatewayv2_route" "auth" {
  for_each = local.auth_route_keys

  api_id = aws_apigatewayv2_api.this.id

  route_key = each.value

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
# Authorizer: valida o JWT (emitido pela lambda acima) nas rotas de negocio.
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
# Rotas de negocio: repassadas direto para o backend (HTTP_PROXY, sem passar
# pela lambda), protegidas pelo authorizer acima. Duas integracoes por
# recurso porque a substituicao de path "{proxy}" do HTTP_PROXY so existe
# quando a rota tem a variavel de path "{proxy+}" - a rota "de colecao"
# (ex: "/clientes") usa uma integracao com URI literal.
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
  request_parameters = { "overwrite:path" = "$request.path" }

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

resource "aws_apigatewayv2_integration" "backend_auth" {
  api_id             = aws_apigatewayv2_api.this.id
  integration_type   = "HTTP_PROXY"
  integration_method = "ANY"
  integration_uri    = var.backend_url
  request_parameters = { "overwrite:path" = "$request.path" }
}
resource "aws_apigatewayv2_route" "backend_auth" {
  for_each  = toset(["POST /auth/login", "POST /auth/chatbot", "POST /auth/change-password"])
  api_id    = aws_apigatewayv2_api.this.id
  route_key = each.value
  target    = "integrations/${aws_apigatewayv2_integration.backend_auth.id}"
}