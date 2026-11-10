
variable "aws_region" {
  description = "AWS region for the lab"
  type        = string
  default     = "ap-southeast-2"
}

variable "project_name" {
  description = "Project identification tag"
  type        = string
  default     = "LifeSciences-CloudOps"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "lab"
}

variable "owner" {
  description = "Resource ownership tag"
  type        = string
  default     = "cloudops-intern"
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnet outbound access"
  type        = bool
  default     = false
}
