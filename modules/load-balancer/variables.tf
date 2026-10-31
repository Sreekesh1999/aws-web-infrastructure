variable "project_name" {
  description = "Project name"
  type        = string
  default     = "aws-web-infrastructure"
}

variable "alb_security_groups" {
  description = "Security groups for the load balancer"
  type        = list(string)
}

variable "subnet_ids" {
  description = "IDs of the subnets for the load balancer"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID for the target group"
  type        = string
}