
# Public Application Load Balancer
resource "aws_lb" "web" {
  name               = "LifeSciences-ALB"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.alb.id
  ]

  subnets = [
    aws_subnet.public["a"].id,
    aws_subnet.public["b"].id
  ]

  tags = {
    Name = "LifeSciences-ALB"
  }
}

# Group of Windows servers behind the ALB
resource "aws_lb_target_group" "web" {
  name        = "LifeSciences-Web-TG"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.main.id

  health_check {
    enabled             = true
    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Name = "LifeSciences-Web-TG"
  }
}

# Listen for browser requests on port 80
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.web.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}
