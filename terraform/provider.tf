
provider "aws" {
  region              = var.aws_region
  allowed_account_ids = ["140864474143"]

  default_tags {
    tags = {
      Project     = var.project_name
      Owner       = var.owner
      Environment = var.environment
      ManagedBy   = "Terraform"
      Purpose     = "CloudOpsInternship"
    }
  }
}
