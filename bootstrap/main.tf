
# S3 bucket for Terraform state
resource "aws_s3_bucket" "terraform_state" {
  bucket = "prem-intern-1st-project-tfstate-140864474143-use1"

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name = "prem-intern-1st-project-tfstate"
  }
}

# Enable bucket versioning
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Enable server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block all public access
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

# Show the created bucket name
output "terraform_state_bucket" {
  value = aws_s3_bucket.terraform_state.id
}
