
# Application Load Balancer for 1st Internship Project
resource "aws_lb" "web" {
  name               = "prem-intern-1st-project-alb"
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
    Name = "prem-intern-1st-project-alb"
  }
}

# Target Group for Windows EC2 web servers
resource "aws_lb_target_group" "web" {
  name        = "prem-intern-1st-project-web-tg"
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
    Name = "prem-intern-1st-project-web-tg"
  }
}

# HTTP Listener for incoming browser requests
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.web.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}
