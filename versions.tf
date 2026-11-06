terraform {
  required_version = ">= 1.10"

  # Shared backend settings. The state key is not here: it comes from
  # backends/<environment>.s3.tfbackend when you run terraform init.
  backend "s3" {
    bucket       = "pg-lab-tfstate-325190458492"
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
}

provider "aws" {
  region = local.config.region

  default_tags {
    tags = {
      Project   = "pg-lab"
      ManagedBy = "terraform"
    }
  }
}

provider "aws" {
  alias  = "west"
  region = local.config.dr_region

  default_tags {
    tags = {
      Project   = "pg-lab"
      ManagedBy = "terraform"
    }
  }
}
