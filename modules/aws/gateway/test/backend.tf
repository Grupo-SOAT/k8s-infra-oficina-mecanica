terraform {
  backend "s3" {
    key    = "aws/gateway-test/terraform.tfstate"
    region = "us-east-1"
  }
}
