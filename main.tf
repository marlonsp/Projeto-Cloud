terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  backend "s3" {
    bucket = "marlonsp-bucket"
    key    = "remote-state/terraform.tfstate"
    region = "us-east-1"
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  profile = "default"
  region = "us-east-1"
}

data "aws_availability_zones" "available" {
  state = "available"
}