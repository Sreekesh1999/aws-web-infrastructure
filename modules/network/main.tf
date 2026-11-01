# Create a VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "aws-web-infrastructure-vpc"
  }

}

# data source to get the available availability zones in the region
data "aws_availability_zones" "available" {
  state = "available"
}

# Create public subnets in the VPC
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "aws-web-infrastructure-public-az${count.index + 1}"
  }

  lifecycle {
    precondition {
      condition     = length(data.aws_availability_zones.available.names) >= 2
      error_message = "At least two available Availability Zones are required."
    }
  }
}

# Create private subnets in the VPC
resource "aws_subnet" "private" {
  count                   = length(var.private_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false
  tags = {
    Name = "aws-web-infrastructure-private-az${count.index + 1}"
  }

  lifecycle {
    precondition {
      condition     = length(data.aws_availability_zones.available.names) >= 2
      error_message = "At least two available Availability Zones are required."
    }
  }
}

# Create dedicated database private subnets in the VPC
resource "aws_subnet" "db_private" {
  count                   = length(var.db_private_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.db_private_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "aws-web-infrastructure-db-private-az${count.index + 1}"
  }

  lifecycle {
    precondition {
      condition     = length(data.aws_availability_zones.available.names) >= 2
      error_message = "At least two available Availability Zones are required."
    }
  }
}

# Create an Internet Gateway for the VPC
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "aws-web-infrastructure-igw"
  }
}

# Create a public route table for the VPC
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "aws-web-infrastructure-public-rt"
  }
}

# Create a route in the public route table to allow internet access
resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

# Associate the public subnets with the public route table
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Create a EIP for each NAT Gateway
resource "aws_eip" "nat" {
  count  = length(aws_subnet.public)
  domain = "vpc"

  tags = {
    Name = "aws-web-infrastructure-nat-eip-${count.index + 1}"
  }
}

# Create a NAT Gateway in each public subnet
resource "aws_nat_gateway" "main" {
  count         = length(aws_subnet.public)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  depends_on    = [aws_internet_gateway.main, aws_route_table_association.public]
  tags = {
    Name = "aws-web-infrastructure-nat-gw-${count.index + 1}"
  }
}

# Create private route tables for the VPC
resource "aws_route_table" "private" {
  count  = length(aws_subnet.private)
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "aws-web-infrastructure-private-rt-${count.index + 1}"
  }
}

# Create a dedicated route table for database private subnets
resource "aws_route_table" "db_private" {
  count  = length(aws_subnet.db_private)
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "aws-web-infrastructure-db-private-rt"
  }
}

# Create a route in the private route table to allow internet access via NAT Gateway
resource "aws_route" "private_nat_gateway" {
  count                  = length(aws_subnet.private)
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[count.index].id
}

# Associate the private subnets with the private route tables
resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# Associate database private subnets with the database route table
resource "aws_route_table_association" "db_private" {
  count          = length(aws_subnet.db_private)
  subnet_id      = aws_subnet.db_private[count.index].id
  route_table_id = aws_route_table.db_private[count.index].id
}
