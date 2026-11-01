output "db_endpoint" {
  description = "The endpoint of the RDS instance"
  value       = aws_db_instance.rds_instance.endpoint
}

output "db_address" {
  description = "RDS database address"
  value       = aws_db_instance.rds_instance.address
}

output "db_secret_arn" {
  description = "Secrets Manager ARN for the RDS master password"
  value       = aws_db_instance.rds_instance.master_user_secret[0].secret_arn
}