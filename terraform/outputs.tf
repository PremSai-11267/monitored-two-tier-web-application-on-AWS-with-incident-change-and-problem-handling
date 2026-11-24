
# AWS Account
output "aws_account_id" {
  description = "AWS account used for deployment"
  value       = "140864474143"
}

# AWS Region
output "configured_region" {
  description = "Selected AWS deployment region"
  value       = var.aws_region
}

# Project Tags
output "project_tags" {
  description = "Default AWS resource tags"

  value = {
    Project     = var.project_name
    Owner       = var.owner
    Environment = var.environment
    ManagedBy   = "Terraform"
    Purpose     = "CloudOpsInternship"
  }
}

# VPC ID
output "vpc_id" {
  description = "VPC ID for Prem's 1st internship project"
  value       = aws_vpc.main.id
}

# Public Subnet IDs
output "public_subnet_ids" {
  description = "Public subnet IDs"
  value = {
    for key, subnet in aws_subnet.public : key => subnet.id
  }
}

# Private Subnet IDs
output "private_subnet_ids" {
  description = "Private subnet IDs"
  value = {
    for key, subnet in aws_subnet.private : key => subnet.id
  }
}

# Application Load Balancer DNS
output "alb_dns_name" {
  description = "Public DNS address of the internship project ALB"
  value       = aws_lb.web.dns_name
}

# Auto Scaling Group
output "autoscaling_group_name" {
  description = "Windows EC2 Auto Scaling Group name"
  value       = aws_autoscaling_group.web.name
}

# PostgreSQL RDS Identifier
output "postgres_db_identifier" {
  description = "PostgreSQL RDS database identifier"
  value       = aws_db_instance.postgres.identifier
}
