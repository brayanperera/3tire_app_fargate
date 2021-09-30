/*==== VPC ======*/
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name        = "${var.common_config.environment}-vpc"
    Environment = var.common_config.environment
  }
}

/*==== Subnets ======*/
/* Internet gateway for the public subnet */
resource "aws_internet_gateway" "int_gw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name        = "${var.common_config.environment}-igw"
    Environment = var.common_config.environment
  }
}

/* Elastic IP for NAT GW */
resource "aws_eip" "nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.int_gw]
}

/* NAT GW */
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = element(aws_subnet.public_subnet.*.id, 0)
  depends_on    = [aws_internet_gateway.int_gw]
  tags = {
    Name        = "nat"
    Environment = var.common_config.environment
  }
}

/* Public subnet */
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = length(var.vpc.public_subnets_cidr)
  cidr_block              = element(var.vpc.public_subnets_cidr,   count.index)
  availability_zone       = element(var.common_config.availability_zones,   count.index)
  map_public_ip_on_launch = true
  tags = {
    Name        = "${var.common_config.environment}-${element(var.common_config.availability_zones, count.index)}-public-subnet"
    Environment = var.common_config.environment
  }
}

/* Private subnet */
resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = length(var.vpc.private_subnets_cidr)
  cidr_block              = element(var.vpc.private_subnets_cidr, count.index)
  availability_zone       = element(var.common_config.availability_zones,   count.index)
  map_public_ip_on_launch = false
  tags = {
    Name        = "${var.common_config.environment}-${element(var.common_config.availability_zones, count.index)}-private-subnet"
    Environment = var.common_config.environment
  }
}

/*==== Route Tables ======*/
/* Routing table for private subnet */
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name        = "${var.common_config.environment}-private-route-table"
    Environment = var.common_config.environment
  }
}

/* Routing table for public subnet */
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name        = "${var.common_config.environment}-public-route-table"
    Environment = var.common_config.environment
  }
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.int_gw.id
}

resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw.id
}

/* Route table associations */
resource "aws_route_table_association" "public" {
  count          = length(var.vpc.public_subnets_cidr)
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "private" {
  count          = length(var.vpc.private_subnets_cidr)
  subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
  route_table_id = aws_route_table.private.id
}