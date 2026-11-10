terraform {
  backend "s3" {
    bucket              = "lifesciences-tfstate-393849326496-apse2"
    key                 = "lifesciences/lab/terraform.tfstate"
    region              = "ap-southeast-2"
    encrypt             = true
    use_lockfile        = true
    allowed_account_ids = ["393849326496"]
  }
}