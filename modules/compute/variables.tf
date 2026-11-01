variable "instance_type" {
  description = "The EC2 instance type to use for the web server."
  type        = string
  default     = "t3.micro"

}

variable "web_security_group_id" {
  description = "The ID of the security group to associate with the web server."
  type        = string
}

variable "instance_profile_name" {
  description = "The name of the IAM instance profile to associate with the web server."
  type        = string
}

variable "private_subnet_ids" {
  description = "A list of private subnet IDs for the Auto Scaling Group."
  type        = list(string)
}

variable "target_group_arns" {
  description = "A list of target group ARNs to associate with the Auto Scaling Group."
  type        = list(string)
}

variable "desired_capacity" {
  description = "The desired number of instances in the Auto Scaling Group."
  type        = number
  default     = 2
}

variable "max_size" {
  description = "The maximum number of instances in the Auto Scaling Group."
  type        = number
  default     = 4
}

variable "min_size" {
  description = "The minimum number of instances in the Auto Scaling Group."
  type        = number
  default     = 2
}