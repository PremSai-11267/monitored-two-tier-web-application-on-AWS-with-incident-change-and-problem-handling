
provider "aws" {
  region              = "us-east-1"
  allowed_account_ids = ["140864474143"]

  default_tags {
    tags = {
      Project   = "Prem_intern_1st_project"
      Owner     = "PremSai"
      ManagedBy = "Terraform"
      Purpose   = "CloudOpsInternship"
    }
  }
}
