data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name = "availability-zone"
    values = [
      "us-east-1a",
      "us-east-1b",
    ]
  }
}

data "aws_region" "current" {}

resource "aws_security_group" "lambda" {
  name        = "${var.project_name}-lambda"
  description = "Security group das Lambdas que acessam o RDS"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Name    = "${var.project_name}-lambda"
    Project = var.project_name
  }
}

resource "aws_vpc_security_group_egress_rule" "lambda_rds" {
  security_group_id = aws_security_group.lambda.id
  description       = "PostgreSQL para o RDS"

  ip_protocol = "tcp"
  from_port   = 5432
  to_port     = 5432

  cidr_ipv4 = data.aws_vpc.default.cidr_block
}

resource "aws_vpc_security_group_egress_rule" "lambda_endpoints" {
  security_group_id = aws_security_group.lambda.id
  description       = "HTTPS para os VPC endpoints"

  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443

  referenced_security_group_id = aws_security_group.vpc_endpoints.id
}

resource "aws_security_group" "vpc_endpoints" {
  name        = "${var.project_name}-vpc-endpoints"
  description = "Security group dos VPC endpoints usados pelas Lambdas"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Name    = "${var.project_name}-vpc-endpoints"
    Project = var.project_name
  }
}

resource "aws_vpc_security_group_ingress_rule" "endpoints_lambda" {
  security_group_id = aws_security_group.vpc_endpoints.id
  description       = "HTTPS vindo das Lambdas"

  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443

  referenced_security_group_id = aws_security_group.lambda.id
}

resource "aws_vpc_security_group_egress_rule" "endpoints_all" {
  security_group_id = aws_security_group.vpc_endpoints.id
  description       = "Saida dos VPC endpoints"

  ip_protocol = "-1"

  cidr_ipv4 = "0.0.0.0/0"
}

resource "aws_vpc_endpoint" "logs" {
  vpc_id = data.aws_vpc.default.id

  service_name = "com.amazonaws.${data.aws_region.current.name}.logs"

  vpc_endpoint_type = "Interface"

  subnet_ids = data.aws_subnets.default.ids

  security_group_ids = [aws_security_group.vpc_endpoints.id]

  private_dns_enabled = true

  tags = {
    Name    = "${var.project_name}-logs"
    Project = var.project_name
  }
}
