
provider "aws" {
  region              = var.aws_region
  allowed_account_ids = ["393849326496"]

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      Owner       = var.owner
      ManagedBy   = "Terraform"
    }
  }
}
