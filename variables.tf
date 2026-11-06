variable "environment" {
  type        = string
  description = "Which environment to deploy. Selects config/<environment>.yaml"

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "environment must be dev or prod."
  }
}
