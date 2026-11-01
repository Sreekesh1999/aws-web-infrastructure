output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.load_balancer.alb_dns_name
}

output "alb_url" {
  description = "URL of the Application Load Balancer"
  value       = "http://${module.load_balancer.alb_dns_name}"
}

output "rds_endpoint" {
  description = "Endpoint of the RDS instance"
  value       = module.database.db_endpoint
}

output "rds_address" {
  description = "Address of the RDS instance"
  value       = module.database.db_address
}

output "rds_secret_arn" {
  description = "Secrets Manager ARN for the RDS master password"
  value       = module.database.db_secret_arn
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.network.vpc_id
}

output "auto_scaling_group_name" {
  description = "Name of the auto scaling group"
  value       = module.compute.auto_scaling_group_name
}