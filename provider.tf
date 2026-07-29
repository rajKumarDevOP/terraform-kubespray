#====================================================================provider.tf========================================
terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  backend "s3" {
    bucket       = "nmims-tfstate" # need to be created first
    key          = "ai_tf.tfstate"
    region       = "ap-south-1"
    use_lockfile = "true"
    encrypt      = true
  }
}

provider "aws" {
  region = var.aws_region
}