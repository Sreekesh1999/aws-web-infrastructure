variable "db_subnet_group_name" {
  description = "The name of the DB subnet group"
  type        = string
  default     = "aws-web-infrastructure"

}

variable "subnet_ids" {
  description = "A list of VPC subnet IDs for the DB subnet group"
  type        = list(string)
}

variable "db_instance_class" {
  description = "The instance class for the RDS instance"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "The allocated storage in gigabytes for the RDS instance"
  type        = number
  default     = 20
}

variable "db_username" {
  description = "The username for the RDS instance"
  type        = string
}

variable "db_security_group_id" {
  description = "The security group ID for the RDS instance"
  type        = string
}
