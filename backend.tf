terraform {
  backend "s3" {
    bucket = "oficina-mecanica-terraform-state"
    key    = "aws/terraform.tfstate"
    region = "us-east-1"
  }
}