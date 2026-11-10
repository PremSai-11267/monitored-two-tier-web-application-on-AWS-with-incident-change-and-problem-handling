
# Find the latest Windows Server 2022 AMI
data "aws_ssm_parameter" "windows_ami" {
  name = "/aws/service/ami-windows-latest/Windows_Server-2022-English-Full-Base"
}

# Windows EC2 Launch Template
resource "aws_launch_template" "web" {
  name_prefix   = "LifeSciences-Web-"
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

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name        = "LifeSciences-Web"
      Project     = var.project_name
      Environment = var.environment
      Owner       = var.owner
    }
  }

  tags = {
    Name = "LifeSciences-Web-Template"
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "web" {
  name = "LifeSciences-Web-ASG"

  # Connect Windows EC2 instances to the ALB Target Group
  target_group_arns = [
    aws_lb_target_group.web.arn
  ]

  # Deploy instances across two private subnets
  vpc_zone_identifier = [
    aws_subnet.private["a"].id,
    aws_subnet.private["b"].id
  ]

  min_size         = 2
  max_size         = 2
  desired_capacity = 2

  health_check_type         = "ELB"
  health_check_grace_period = 600

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  tag {
    key                 = "Project"
    value               = var.project_name
    propagate_at_launch = true
  }
  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }

  tag {
    key                 = "PatchGroup"
    value               = "LifeSciences-Windows-Web"
    propagate_at_launch = true
  }
}
