# Bootstrap: the things the pipeline needs before it can run.
# Its own state stays local on your laptop (chicken-and-egg: the state
# bucket can't store the state of the code that creates it).
terraform {
  required_version = ">= 1.10"




  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project   = "pg-lab"
      Component = "bootstrap"
      ManagedBy = "terraform"
    }
  }
}
