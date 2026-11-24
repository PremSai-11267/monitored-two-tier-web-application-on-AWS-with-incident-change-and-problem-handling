
# VPC for Prem's 1st Internship Project
resource "aws_vpc" "main" {
  cidr_block           = "10.30.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "prem-intern-1st-project-vpc"
  }
}

# Two public subnets
resource "aws_subnet" "public" {
  for_each = {
    a = { cidr = "10.30.1.0/24", az = "us-east-1a" }
    b = { cidr = "10.30.2.0/24", az = "us-east-1b" }
  }

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = false

  tags = {
    Name = "prem-intern-1st-project-public-${each.key}"
    Tier = "public"
  }
}

# Two private subnets
resource "aws_subnet" "private" {
  for_each = {
    a = { cidr = "10.30.11.0/24", az = "us-east-1a" }
    b = { cidr = "10.30.12.0/24", az = "us-east-1b" }
  }

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name = "prem-intern-1st-project-private-${each.key}"
    Tier = "private"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "prem-intern-1st-project-igw"
  }
}

# Public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "prem-intern-1st-project-public-rt"
  }
}

# Associate public subnets with public route table
resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# Private route table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "prem-intern-1st-project-private-rt"
  }
}

# Associate private subnets with private route table
resource "aws_route_table_association" "private" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  count  = var.enable_nat_gateway ? 1 : 0
  domain = "vpc"

  tags = {
    Name = "prem-intern-1st-project-nat-eip"
  }
}

# NAT Gateway (optional)
resource "aws_nat_gateway" "main" {
  count         = var.enable_nat_gateway ? 1 : 0
  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public["a"].id

  depends_on = [aws_internet_gateway.main]

  tags = {
    Name = "prem-intern-1st-project-nat"
  }
}

# Private outbound internet route through NAT
resource "aws_route" "private_nat" {
  count                  = var.enable_nat_gateway ? 1 : 0
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[0].id
}
