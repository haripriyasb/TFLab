output "state_bucket" {
  description = "Put this in the backend block of pg-lab/versions.tf"
  value       = aws_s3_bucket.state.bucket
}

output "plan_role_arn" {
  description = "GitHub repo variable AWS_PLAN_ROLE_ARN"
  value       = aws_iam_role.plan.arn
}

output "apply_role_arn" {
  description = "GitHub repo variable AWS_APPLY_ROLE_ARN"
  value       = aws_iam_role.apply.arn
}
