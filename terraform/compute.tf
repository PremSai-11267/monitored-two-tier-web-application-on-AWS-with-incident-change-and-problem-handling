
# ============================================================
# 1st Internship Project - Windows EC2 and Auto Scaling
# ============================================================

# Find the latest Windows Server 2022 AMI
data "aws_ssm_parameter" "windows_ami" {
  name = "/aws/service/ami-windows-latest/Windows_Server-2022-English-Full-Base"
}

# Windows EC2 Launch Template
resource "aws_launch_template" "web" {
  name_prefix   = "prem-intern-1st-project-web-"
  image_id      = data.aws_ssm_parameter.windows_ami.value
  instance_type = "m7i-flex.large"

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_ssm.name
  }

  vpc_security_group_ids = [
    aws_security_group.web.id
  ]

  user_data = filebase64("${path.module}/iis-userdata.xml")

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  # Tags for EC2 instances launched by the ASG
  tag_specifications {
    resource_type = "instance"

    tags = {
      Name      = "prem-intern-1st-project-web"
      Project   = var.project_name
      Owner     = var.owner
      ManagedBy = "Terraform"
      Purpose   = "CloudOpsInternship"
    }
  }

  tags = {
    Name = "prem-intern-1st-project-web-template"
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "web" {
  name = "prem-intern-1st-project-web-asg"

  # Connect Windows EC2 instances to ALB Target Group
  target_group_arns = [
    aws_lb_target_group.web.arn
  ]

  # Deploy instances across two private subnets
  vpc_zone_identifier = [
    aws_subnet.private["a"].id,
    aws_subnet.private["b"].id
  ]

  # Cost-controlled initial configuration
  min_size         = 0
  max_size         = 2
  desired_capacity = 1

  health_check_type         = "ELB"
  health_check_grace_period = 600

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  # Resource identification
  tag {
    key                 = "Name"
    value               = "prem-intern-1st-project-web"
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = var.project_name
    propagate_at_launch = true
  }

  tag {
    key                 = "Owner"
    value               = var.owner
    propagate_at_launch = true
  }

  tag {
    key                 = "ManagedBy"
    value               = "Terraform"
    propagate_at_launch = true
  }

  tag {
    key                 = "Purpose"
    value               = "CloudOpsInternship"
    propagate_at_launch = true
  }

  # Patch Manager tag
  tag {
    key                 = "PatchGroup"
    value               = "prem-intern-1st-project-windows-web"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }
}
