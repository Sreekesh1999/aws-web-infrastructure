variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "ap-south-1"

}

variable "db_username" {
  description = "The username for the RDS instance"
  type        = string

}