terraform {
  required_providers {
    aws={
        source = "hashicorp/aws"
        version = "6.22.1"
    }
  }

  backend "s3" {
    bucket = "mys3bucket402"
    key = "terraform.tfstate"
    region = "us-east-2"
    dynamodb_table = "mydbtable"
  }
}