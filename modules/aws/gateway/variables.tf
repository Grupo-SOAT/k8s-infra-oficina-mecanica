variable "api_name" {
  type        = string
  description = "Nome da API Gateway"
}

variable "lambda_arn" {
  type        = string
  description = "ARN da Lambda integrada ao API Gateway. Deixe em branco para não criar integração, rotas nem permissão nenhuma — útil para testar isoladamente a criação da API Gateway e seu domínio, sem depender de uma Lambda existente."
  default     = ""
}

variable "project_name" {
  type        = string
  description = "Nome do projeto"
}

variable "lambda_function_name" {
    type = string
    description = "nome da function lambda que será chamada pelo gateway. Só é usado (e só precisa existir) quando lambda_arn não está vazio."
    default = ""
}

variable "resources" {
  type        = list(string)
  description = "Contrato de rotas do gateway: um item por recurso do monólito (ex: \"clientes\", \"veiculos\"). Para cada item são criadas as rotas \"ANY /{recurso}\" e \"ANY /{recurso}/{proxy+}\", ambas roteadas para a Lambda validator."
}

variable "throttling_rate_limit" {
  type        = number
  description = "Limite de requisições por segundo (steady-state), aplicado por rota no stage padrão"
  default     = 50
}

variable "throttling_burst_limit" {
  type        = number
  description = "Limite de requisições em rajada, aplicado por rota no stage padrão"
  default     = 100
}

variable "permission_statement_id" {
  type        = string
  description = "statement_id da permissão de invocação concedida ao API Gateway na Lambda. Precisa ser único por Lambda: se mais de uma API (ex: produção e um harness de teste) apontar para a mesma função, cada uma precisa de um statement_id diferente para não conflitar."
  default     = "AllowApiGatewayInvoke"
}
