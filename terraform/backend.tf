terraform {
  backend "s3" {
    bucket              = "prem-intern-1st-project-tfstate-140864474143-use1"
    key                 = "prem-intern-1st-project/terraform.tfstate"
    region              = "us-east-1"
    encrypt             = true
    use_lockfile        = true
    allowed_account_ids = ["140864474143"]
  }

}
