provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Project     = "aws-web-infrastructure"
      Environment = "dev"
      ManagedBy   = "Terraform"
    }
  }

}