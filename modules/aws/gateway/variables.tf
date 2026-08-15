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