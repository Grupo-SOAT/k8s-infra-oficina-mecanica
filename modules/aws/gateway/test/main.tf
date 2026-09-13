module "gateway_under_test" {
  source = "../"

  api_name = var.api_name

  project_name = var.project_name

  resources = var.resources
}

# Rota fictícia, só deste harness: sem Lambda disponível (bloqueio de iam:PassRole),
# usa HTTP_PROXY contra um serviço público de echo pra provar que o gateway
# roteia e devolve resposta de verdade. HTTP API não suporta integração MOCK
# (isso só existe em REST API / API Gateway v1).
resource "aws_apigatewayv2_integration" "mock" {
  api_id = module.gateway_under_test.api_id

  integration_type   = "HTTP_PROXY"
  integration_method = "GET"
  integration_uri    = "https://postman-echo.com/get"

  payload_format_version = "1.0"
}

resource "aws_apigatewayv2_route" "mock" {
  api_id = module.gateway_under_test.api_id

  route_key = "GET /mock"

  target = "integrations/${aws_apigatewayv2_integration.mock.id}"
}
