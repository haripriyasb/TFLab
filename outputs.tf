output "instance_id" {
  value = aws_instance.pg.id
}

output "private_ip" {
  value = aws_instance.pg.private_ip
}

output "connect_command" {
  description = "Run this if you have the Session Manager plugin installed"
  value       = "aws ssm start-session --target ${aws_instance.pg.id} --region ${local.config.region}"
}
