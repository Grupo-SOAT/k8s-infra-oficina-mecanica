variable "function_name" {

  type = string

  description = "Nome da função Lambda"

}


variable "project_name" {

  type = string

}


variable "runtime" {

  type = string

  default = "python3.12"

}


variable "handler" {

  type = string

  default = "lambda_function.lambda_handler"

}


variable "lambda_s3_bucket" {
  type = string
}

variable "lambda_s3_key" {
  type = string
}

variable "source_code_hash" {
  type      = string
  sensitive = false
}


variable "timeout" {

  type = number

  default = 30

}


variable "memory_size" {

  type = number

  default = 256

}


variable "aws_lab_role_arn" {

  type = string

  description = "ARN da LabRole fornecida pelo AWS Academy"

}


variable "database_host" {

  type        = string
  description = "Host do Postgres (RDS gerenciado, ver repo db-oficina-mecanica) que a lambda consulta para validar o cliente"
  default     = ""

}


variable "database_port" {

  type    = number
  default = 5432

}


variable "database_name" {

  type    = string
  default = "workshop"

}


variable "database_user" {

  type        = string
  description = "Usuario do banco usado pela lambda"
  default     = ""

  sensitive = true

}


variable "database_password" {

  type        = string
  description = "Senha do banco usada pela lambda"
  default     = ""

  sensitive = true

}


variable "jwt_secret" {

  type        = string
  description = "Mesmo valor de security.jwt.secret do monolito, para a lambda assinar e validar o JWT"

  sensitive = true

}


variable "vpc_subnet_ids" {

  type        = list(string)
  description = "Subnets em que a lambda sera executada. Vazio mantem a lambda fora da VPC."
  default     = []

}


variable "vpc_security_group_ids" {

  type        = list(string)
  description = "Security groups da lambda quando executada dentro da VPC"
  default     = []

}
