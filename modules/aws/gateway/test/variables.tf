variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "project_name" {
  type    = string
  default = "oficina-mecanica"
}

variable "aws_lab_role_arn" {
  type        = string
  description = "ARN da LabRole a usar no Lambda dummy. Deixe em branco (padrão) para resolver automaticamente a LabRole da conta AWS Academy atual — evita fixar um account id que muda a cada reset de sessão do lab."
  default     = ""
}

variable "api_name" {
  type        = string
  description = "Nome da API Gateway criada só para este teste isolado"
  default     = "oficina-mecanica-api-gateway-test"
}

variable "dummy_lambda_name" {
  type        = string
  description = "Nome do Lambda dummy (sempre responde 200) usado só para validar o roteamento do gateway, sem depender do Lambda validator real"
  default     = "oficina-mecanica-gateway-test-echo"
}

variable "resources" {
  type        = list(string)
  description = "Recursos a testar no gateway, no mesmo formato do contrato usado na stack principal (var.gateway_resources)"
  default     = ["clientes"]
}
