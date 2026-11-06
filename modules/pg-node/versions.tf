# A module says which provider it needs, but never configures it.
# The caller decides which region/account by passing a provider in.
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}
