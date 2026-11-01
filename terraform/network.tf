
# ==========================================
# T02 - AWS VPC AND NETWORKING
# ==========================================

# Get available Availability Zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Define four subnets
locals {
  subnets = {
    public_a = {
      cidr     = "10.20.1.0/24"
      az_index = 0
      public   = true
    }

    public_b = {
      cidr     = "10.20.2.0/24"
      az_index = 1
      public   = true
    }

    private_a = {
      cidr     = "10.20.11.0/24"
      az_index = 0
      public   = false
    }

    private_b = {
      cidr     = "10.20.12.0/24"
      az_index = 1
      public   = false
    }
  }
}

# Create VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.20.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# Create two public and two private subnets
resource "aws_subnet" "subnets" {
  for_each = local.subnets

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = data.aws_availability_zones.available.names[each.value.az_index]

  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project_name}-${each.key}"
    Tier = each.value.public ? "public" : "private"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

# Associate public subnets with public route table
resource "aws_route_table_association" "public" {
  for_each = {
    for name, subnet in local.subnets :
    name => subnet if subnet.public
  }

  subnet_id      = aws_subnet.subnets[each.key].id
  route_table_id = aws_route_table.public.id
}

# NAT Gateway Elastic IP
resource "aws_eip" "nat" {
  count = var.enable_nat_gateway ? 1 : 0

  domain = "vpc"

  tags = {
    Name = "${var.project_name}-nat-eip"
  }
}

# NAT Gateway (disabled by default)
resource "aws_nat_gateway" "main" {
  count = var.enable_nat_gateway ? 1 : 0

  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.subnets["public_a"].id

  depends_on = [aws_internet_gateway.main]

  tags = {
    Name = "${var.project_name}-nat"
  }
}

# Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  dynamic "route" {
    for_each = var.enable_nat_gateway ? [1] : []

    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.main[0].id
    }
  }

  tags = {
    Name = "${var.project_name}-private-rt"
  }
}

# Associate private subnets with private route table
resource "aws_route_table_association" "private" {
  for_each = {
    for name, subnet in local.subnets :
    name => subnet if !subnet.public
  }

  subnet_id      = aws_subnet.subnets[each.key].id
  route_table_id = aws_route_table.private.id
}
