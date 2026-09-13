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

# Contrato real, lido diretamente de openapi/api.yaml + openapi/endpoints/*.yaml
# via yamldecode — nada aqui é retranscrito à mão, então não tem como divergir
# do contrato. yamldecode já descarta comentários do YAML, então paths
# comentados no api.yaml (suppliers, purchase-orders, os 2 relatórios) nem
# aparecem em openapi_spec.paths, sem precisar filtrar nada manualmente.
# Todas as rotas apontam pro mesmo mock: aqui o objetivo é validar que o
# contrato inteiro sobe no API Gateway (sintaxe de path, sem conflitos, sem
# esbarrar em limite de rotas), não o comportamento de negócio de cada uma.
locals {
  openapi_spec      = yamldecode(file("${path.module}/openapi/api.yaml"))
  openapi_base_path = local.openapi_spec.servers[0].url

  http_methods = ["get", "post", "put", "patch", "delete"]

  contract_route_keys = toset(flatten([
    for endpoint_path, ref in local.openapi_spec.paths : [
      for method in local.http_methods :
      "${upper(method)} ${local.openapi_base_path}${endpoint_path}"
      if contains(
        keys(yamldecode(file("${path.module}/openapi/${trimprefix(ref["$ref"], "./")}"))),
        method
      )
    ]
  ]))
}

resource "aws_apigatewayv2_route" "contract" {
  for_each = local.contract_route_keys

  api_id = module.gateway_under_test.api_id

  route_key = each.value

  target = "integrations/${aws_apigatewayv2_integration.mock.id}"
}
