variable "region" {
  type    = string
  default = "us-east-1"
}

variable "github_owner" {
  type        = string
  description = "Your GitHub username (case must match exactly)"
}

variable "github_repo" {
  type        = string
  description = "Repository name, for example pg-lab"
}


variable "github_owner_id" {
  type        = string
  description = "Numeric GitHub account ID, from the OIDC sub claim"
}

variable "github_repo_id" {
  type        = string
  description = "Numeric GitHub repository ID, from the OIDC sub claim"
}