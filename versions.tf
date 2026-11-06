terraform {
  required_version = ">= 1.6"

    backend "s3" {
    bucket       = "pg-lab-tfstate-325190458492"
    key          = "pg-lab/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # State is local for now. Later step: move it to an S3 backend.
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project   = "pg-lab"
      ManagedBy = "terraform"
    }
  }
}


provider "aws" {
  alias  = "west"
  region = var.dr_region

  default_tags {
    tags = {
      Project   = "pg-lab"
      ManagedBy = "terraform"
    }
  }
}