
# IAM configuration for Prem's 1st Internship Project

# Allow EC2 instances to assume the IAM role
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

# IAM role for Windows EC2 web servers
resource "aws_iam_role" "ec2_ssm" {
  name               = "prem-intern-1st-project-ec2-ssm-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_trust.json

  tags = {
    Name = "prem-intern-1st-project-ec2-ssm-role"
  }
}

# Attach AWS-managed Systems Manager permissions
resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2_ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# IAM instance profile for the EC2 launch template
resource "aws_iam_instance_profile" "ec2_ssm" {
  name = "prem-intern-1st-project-ec2-ssm-profile"
  role = aws_iam_role.ec2_ssm.name
}

# ============================================================
# Application Secrets Manager access
# ============================================================
# To be configured for the company AWS account.
#
# The previous manually created policy and secret belonged
# to the personal AWS account.
#
# If the application retrieves database credentials from
# Secrets Manager, a new secret and least-privilege IAM
# permissions must be configured before application testing.
# ============================================================
