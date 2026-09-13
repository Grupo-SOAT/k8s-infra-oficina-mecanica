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

variable "lambda_function_name" {
  type        = string
  description = "Nome da Lambda validator já implantada pela stack principal (module.lambda em main.tf), lida via data source. Precisa já existir na conta/região atual."
  default     = "oficina-mecanica-validator"
}

variable "resources" {
  type        = list(string)
  description = "Recursos a testar no gateway, no mesmo formato do contrato usado na stack principal (var.gateway_resources)"
  default     = ["clientes"]
}
