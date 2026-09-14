terraform {
  backend "s3" {
    key    = "aws/terraform.tfstate"
    region = "us-east-1"
  }
}
