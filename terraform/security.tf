
# Security Groups for 1st Internship Project

# Application Load Balancer Security Group
resource "aws_security_group" "alb" {
  name        = "prem-intern-1st-project-alb-sg"
  description = "Security group for Prem internship project ALB"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "prem-intern-1st-project-alb-sg"
  }
}

# Windows EC2 Web Server Security Group
resource "aws_security_group" "web" {
  name        = "prem-intern-1st-project-web-sg"
  description = "Security group for internship Windows web servers"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "prem-intern-1st-project-web-sg"
  }
}

# PostgreSQL RDS Security Group
resource "aws_security_group" "db" {
  name        = "prem-intern-1st-project-db-sg"
  description = "Security group for internship PostgreSQL RDS"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "prem-intern-1st-project-db-sg"
  }
}

# Internet -> ALB on HTTP 80
resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}

# ALB -> Windows web servers on HTTP 80
resource "aws_vpc_security_group_ingress_rule" "web_http" {
  security_group_id            = aws_security_group.web.id
  referenced_security_group_id = aws_security_group.alb.id
  ip_protocol                  = "tcp"
  from_port                    = 80
  to_port                      = 80
}

# Windows web servers -> PostgreSQL on port 5432
resource "aws_vpc_security_group_ingress_rule" "db_postgres" {
  security_group_id            = aws_security_group.db.id
  referenced_security_group_id = aws_security_group.web.id
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
}

# ALB outbound to Windows web servers
resource "aws_vpc_security_group_egress_rule" "alb_to_web" {
  security_group_id            = aws_security_group.alb.id
  referenced_security_group_id = aws_security_group.web.id
  ip_protocol                  = "tcp"
  from_port                    = 80
  to_port                      = 80
}

# Windows web servers outbound to PostgreSQL
resource "aws_vpc_security_group_egress_rule" "web_to_db" {
  security_group_id            = aws_security_group.web.id
  referenced_security_group_id = aws_security_group.db.id
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
}

# Windows web servers outbound HTTPS
resource "aws_vpc_security_group_egress_rule" "web_https" {
  security_group_id = aws_security_group.web.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
}

# Windows web servers outbound HTTP for updates
resource "aws_vpc_security_group_egress_rule" "web_http_updates" {
  security_group_id = aws_security_group.web.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}
