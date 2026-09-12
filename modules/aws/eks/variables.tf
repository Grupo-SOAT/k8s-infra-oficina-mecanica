variable "cluster_name" {
  type        = string
  description = "Nome do cluster EKS"
}

variable "cluster_version" {
  type    = string
  default = "1.34"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Lista de IDs de subnets (Requer pelo menos duas AZs)"
}

variable "instance_types" {
  type    = list(string)
  default = ["t3.medium"] # <--- t3.small/medium sao aceitos no Learner Lab
}

variable "desired_size" {
  type    = number
  default = 4
}
variable "max_size" {
  type    = number
  default = 5
}

variable "min_size" {
  type    = number
  default = 3
}

# NOVA VARIÁVEL PARA O AMBIENTE DE ESTUDANTE:
variable "aws_academy_role_arn" {
  type        = string
  description = "ARN da LabRole padrao do AWS Academy"
}
