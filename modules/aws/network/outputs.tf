output "vpc_id" {

  value = data.aws_vpc.default.id

}

output "subnet_ids" {

  value = data.aws_subnets.default.ids

}

output "vpc_cidr_block" {
  value = data.aws_vpc.default.cidr_block
}