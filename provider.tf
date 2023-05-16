provider "aws" {
  region  = "eu-central-1"
  profile = "SimonAWS"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}
    