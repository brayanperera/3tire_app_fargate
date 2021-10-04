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
  count = length(var.vpc.private_subnets_cidr)
  vpc        = true
  depends_on = [aws_internet_gateway.int_gw]
}

/* NAT GW */
resource "aws_nat_gateway" "nat_gw" {
  count = length(var.vpc.private_subnets_cidr)
  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id     = aws_subnet.public_subnet[count.index].id
  depends_on    = [aws_internet_gateway.int_gw]
  tags = {
    Name        = "nat-${count.index}"
    Environment = var.common_config.environment
  }
}

/*==== Route Tables ======*/
/* Routing table for public subnet */
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name        = "${var.common_config.environment}-public-route-table"
    Environment = var.common_config.environment
  }
}

/* Routing table for private subnet */
resource "aws_route_table" "private" {
  count = length(var.vpc.private_subnets_cidr)
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name        = "${var.common_config.environment}-rt-${aws_subnet.private_subnet[count.index].id}"
    Environment = var.common_config.environment
  }
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.int_gw.id
}

resource "aws_route" "private_nat_gateway" {
  count = length(var.vpc.private_subnets_cidr)
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw[count.index].id
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
  route_table_id = aws_route_table.private[count.index].id
}

/* Flow logs */

resource "aws_cloudwatch_log_group" "vpc_flow_log" {
  name = "${var.vpc.vpc_name}-flow-logs"
}

resource "aws_iam_role" "vpc_flow_log" {
  name = "vpc_flow_log"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "vpc_flow_log" {
  name = "${var.vpc.vpc_name}-flow-logs"
  role = aws_iam_role.vpc_flow_log.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_flow_log" "vpc_flow_log" {
  iam_role_arn    = aws_iam_role.vpc_flow_log.arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_log.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.vpc.id
}



