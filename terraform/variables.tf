
variable "aws_region" {
  description = "AWS deployment region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Internship project name"
  type        = string
  default     = "Prem_intern_1st_project"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "internship"
}

variable "owner" {
  description = "Resource owner"
  type        = string
  default     = "PremSai"
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnet internet access"
  type        = bool
  default     = false
}
