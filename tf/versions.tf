provider "aws" {
  region = "eu-west-1"
}

terraform {
  required_version = ">= 1.11.2"

  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

  backend "s3" {
    bucket       = "paulina-tf-remote-backend"
    key          = "tech-task"
    region       = "eu-west-1"
    encrypt      = true
    use_lockfile = true
  }
}