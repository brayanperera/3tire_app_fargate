terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
    github = {
      source  = "integrations/github"
      version = "4.14.0"
    }
  }
}

provider "aws" {
  region = var.common_config.region
}

provider "github" {
}