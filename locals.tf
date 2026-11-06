# All per-environment settings come from config/<environment>.yaml
locals {
  config = yamldecode(file("${path.module}/config/${var.environment}.yaml"))
}
