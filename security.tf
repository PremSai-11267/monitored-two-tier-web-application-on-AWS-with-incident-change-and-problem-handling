
# Three security groups inside our new VPC

resource "aws_security_group" "alb" {
  name        = "LifeSciences-ALB-SG"
  description = "Security group for public ALB"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "LifeSciences-ALB-SG"
  }
}

resource "aws_security_group" "web" {
  name        = "LifeSciences-Web-SG"
  description = "Security group for Windows web servers"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "LifeSciences-Web-SG"
  }
}

resource "aws_security_group" "db" {
  name        = "LifeSciences-DB-SG"
  description = "Security group for PostgreSQL RDS"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "LifeSciences-DB-SG"
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

# Windows web servers -> PostgreSQL on 5432
resource "aws_vpc_security_group_ingress_rule" "db_postgres" {
  security_group_id            = aws_security_group.db.id
  referenced_security_group_id = aws_security_group.web.id
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
}

# ALB outbound to web servers
resource "aws_vpc_security_group_egress_rule" "alb_to_web" {
  security_group_id            = aws_security_group.alb.id
  referenced_security_group_id = aws_security_group.web.id
  ip_protocol                  = "tcp"
  from_port                    = 80
  to_port                      = 80
}

# Web servers outbound to PostgreSQL
resource "aws_vpc_security_group_egress_rule" "web_to_db" {
  security_group_id            = aws_security_group.web.id
  referenced_security_group_id = aws_security_group.db.id
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
}

# Web servers outbound HTTPS for AWS services and updates
resource "aws_vpc_security_group_egress_rule" "web_https" {
  security_group_id = aws_security_group.web.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
}
# Windows web servers outbound HTTP for Windows Update downloads
resource "aws_vpc_security_group_egress_rule" "web_http_updates" {
  security_group_id = aws_security_group.web.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}