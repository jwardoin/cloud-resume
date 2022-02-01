terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.68"
    }
  }
  cloud {
    organization = "JordanArdoin"
    workspaces {
      name = "CRC-Terraform-Automate"
    }
  }
}

provider "aws" {
  shared_credentials_file = "~/.aws/credentials"
  profile = "default"
  region  = "us-east-1"

}
