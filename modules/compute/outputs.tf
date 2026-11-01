output "auto_scaling_group_name" {
  description = "Name of the auto scaling group"
  value       = aws_autoscaling_group.asg.name
}

output "auto_scaling_group_arn" {
  description = "ARN of the auto scaling group"
  value       = aws_autoscaling_group.asg.arn
}

output "launch_template_id" {
  description = "ID of the launch template"
  value       = aws_launch_template.web_server.id
}