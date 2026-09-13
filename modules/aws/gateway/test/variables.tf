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
  description = "ARN da LabRole a usar na Lambda. Deixe em branco (padrão) para resolver automaticamente pela conta AWS Academy atual — evita fixar um account id que muda a cada reset de sessão do lab."
  default     = ""
}

variable "api_name" {
  type        = string
  description = "Nome da API Gateway criada só para este teste isolado"
  default     = "oficina-mecanica-api-gateway-test"
}

variable "function_name" {
  type        = string
  description = "Nome da Lambda. Igual ao da stack principal (oficina-mecanica-validator) porque ela ainda não foi criada nesta conta — se algum dia for criada por lá também, as duas passam a disputar o mesmo recurso físico."
  default     = "oficina-mecanica-validator"
}

variable "runtime" {
  type    = string
  default = "java21"
}

variable "handler" {
  type    = string
  default = "br.com.oficina.lambda.ValidatorHandler::handleRequest"
}

variable "lambda_s3_bucket" {
  type        = string
  description = "Bucket S3 onde o artefato da Lambda validator é publicado (mesmo usado pela stack principal)"
  default     = "lambda-code-archive-oficina-mecanica"
}

variable "lambda_s3_key" {
  type        = string
  description = "Key do artefato da Lambda no S3. Sem default: o workflow descobre o mais recente automaticamente antes do apply."
}

variable "source_code_hash" {
  type        = string
  description = "SHA256 em base64 do artefato no S3. Sem default: o workflow calcula automaticamente antes do apply."
}

variable "timeout" {
  type    = number
  default = 30
}

variable "memory_size" {
  type    = number
  default = 256
}

variable "database_user_secret_arn" {
  type        = string
  description = "ARN da secret com o usuário do banco. Placeholder vazio não impede o deploy da Lambda (só o runtime real dela, ao ser invocada, dependeria disso)."
  default     = ""
}

variable "database_password_secret_arn" {
  type    = string
  default = ""
}

variable "database_host" {
  type    = string
  default = ""
}

variable "database_port" {
  type    = number
  default = 5432
}

variable "database_name" {
  type    = string
  default = "workshop"
}

variable "jwt_secret_arn" {
  type    = string
  default = ""
}

variable "backend_url" {
  type    = string
  default = "http://localhost:8080"
}

variable "resources" {
  type        = list(string)
  description = "Recursos a testar no gateway, no mesmo formato do contrato usado na stack principal (var.gateway_resources)"
  default     = ["clientes"]
}
