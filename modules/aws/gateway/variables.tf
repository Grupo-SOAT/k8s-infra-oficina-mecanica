variable "api_name" {
  type        = string
  description = "Nome da API Gateway"
}

variable "lambda_arn" {
  type        = string
  description = "ARN da Lambda integrada ao API Gateway"
}

variable "project_name" {
  type        = string
  description = "Nome do projeto"
}

variable "lambda_function_name" {
    type = string
    description = "nome da function lambda que será chamada pelo gateway"
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
