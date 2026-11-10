
output "configured_region" {
  description = "Selected AWS region"
  value       = var.aws_region
}

output "project_tags" {
  description = "Default AWS resource tags"

  value = {
    Project     = var.project_name
    Environment = var.environment
    Owner       = var.owner
    ManagedBy   = "Terraform"
  }
}

output "alb_dns_name" {
  description = "Public DNS address of the Life Sciences ALB"
  value       = aws_lb.web.dns_name
}