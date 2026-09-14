variable "api_name" {
  type        = string
  description = "Nome da API Gateway"
}

variable "lambda_arn" {
  type        = string
  description = "ARN da Lambda integrada ao API Gateway. Deixe em branco para não criar integração, rotas nem permissão da Lambda."
  default     = ""
}

variable "project_name" {
  type        = string
  description = "Nome do projeto"
}

variable "lambda_function_name" {
  type        = string
  description = "Nome da função Lambda que será chamada pelo API Gateway. Só é usado quando lambda_arn não está vazio."
  default     = ""
}

variable "resources" {
  type        = list(string)
  description = "Contrato de rotas protegidas do gateway: um item por recurso do monólito (ex: \"clientes\", \"veiculos\"). Para cada item são criadas as rotas \"ANY /{recurso}\" e \"ANY /{recurso}/{proxy+}\", repassadas diretamente para o backend (HTTP_PROXY) e protegidas pelo authorizer."
}

variable "auth_resource" {
  type        = string
  description = "Nome do recurso de autenticação usado pela rota POST /{auth_resource}/cpf, direcionada para a Lambda validator."
  default     = "auth"
}

variable "authorizer_invoke_arn" {
  type        = string
  description = "Invoke ARN da Lambda authorizer, responsável por validar o JWT nas rotas de negócio."
}

variable "authorizer_function_name" {
  type        = string
  description = "Nome da função Lambda authorizer, usada para autorizar o API Gateway a invocá-la."
}

variable "authorizer_result_ttl_in_seconds" {
  type        = number
  description = "Por quanto tempo o API Gateway cacheia a decisão do authorizer para o mesmo token. 0 desabilita o cache."
  default     = 0
}

variable "backend_url" {
  type        = string
  description = "URL do backend (load balancer do EKS) para onde as rotas de negócio são repassadas diretamente."
}

variable "throttling_rate_limit" {
  type        = number
  description = "Limite de requisições por segundo (steady-state), aplicado por rota no stage padrão."
  default     = 50
}

variable "throttling_burst_limit" {
  type        = number
  description = "Limite de requisições em rajada, aplicado por rota no stage padrão."
  default     = 100
}

variable "permission_statement_id" {
  type        = string
  description = "Statement ID da permissão de invocação concedida ao API Gateway na Lambda. Precisa ser único por Lambda."
  default     = "AllowApiGatewayInvoke"
}