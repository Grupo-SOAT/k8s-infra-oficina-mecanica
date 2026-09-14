variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "project_name" {
  type    = string
  default = "oficina-mecanica"
}

variable "api_name" {
  type        = string
  description = "Nome da API Gateway criada só para este teste isolado"
  default     = "oficina-mecanica-api-gateway-test"
}

variable "resources" {
  type        = list(string)
  description = "Contrato de rotas, no mesmo formato usado na stack principal (var.gateway_resources). Sem efeito enquanto o teste não tiver uma Lambda integrada — nenhuma rota é criada nesse caso."
  default     = ["clientes"]
}
