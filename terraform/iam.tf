
# Allow EC2 instances to assume this IAM role
data "aws_iam_policy_document" "ec2_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# IAM role for Windows EC2
resource "aws_iam_role" "ec2_ssm" {
  name               = "LifeSciences-EC2-SSM-Role"
  assume_role_policy = data.aws_iam_policy_document.ec2_trust.json

  tags = {
    Name = "LifeSciences-EC2-SSM-Role"
  }
}

# Attach AWS-managed Systems Manager permissions
resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2_ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Instance profile for the EC2 launch template
resource "aws_iam_instance_profile" "ec2_ssm" {
  name = "LifeSciences-EC2-SSM-Profile"
  role = aws_iam_role.ec2_ssm.name
}

# ============================================================
# T08 - Secrets Manager application access
# ============================================================
# STATUS: Already created manually in AWS and working.
# IAM Role: LifeSciences-EC2-SSM-Role
# Policy: LifeSciences-AppDb-ReadSecret
# Purpose: Allow Flask on EC2 to retrieve its PostgreSQL password.
#
# Currently commented out to avoid Terraform changes.
# If Terraform needs to manage the EXISTING policy, uncomment
# both the resource/data blocks and the import block.
#
# data "aws_secretsmanager_secret" "app_db" {
#   name = "lifesciences/lab/app-db"
# }
#
# resource "aws_iam_role_policy" "app_db_read_secret" {
#   name = "LifeSciences-AppDb-ReadSecret"
#   role = aws_iam_role.ec2_ssm.name
#
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect   = "Allow"
#         Action   = ["secretsmanager:GetSecretValue"]
#         Resource = data.aws_secretsmanager_secret.app_db.arn
#       }
#     ]
#   })
# }
#
# import {
#   to = aws_iam_role_policy.app_db_read_secret
#   id = "LifeSciences-EC2-SSM-Role:LifeSciences-AppDb-ReadSecret"
# }
# ============================================================
