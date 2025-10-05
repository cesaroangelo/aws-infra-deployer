# Used the AWS Terraform Provider.
# AWS Provider: https://registry.terraform.io/providers/hashicorp/aws/latest/docs

# Provides a VPC resource.
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = var.vpc_name
  }
}

locals {
  target_availability_zones = var.single_az ? [var.availability_zones[0]] : var.availability_zones
  public_subnet_count       = length(local.target_availability_zones)
  private_netnums           = var.single_az ? [3] : range(max(0, 8 - local.public_subnet_count), 8)
}

# Provides an VPC subnet resource (public).
resource "aws_subnet" "public" {
  count = local.public_subnet_count
  cidr_block = cidrsubnet(var.vpc_cidr, 8, count.index)
  vpc_id     = aws_vpc.main.id
  availability_zone       = local.target_availability_zones[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "Public Subnet ${count.index}"
  }
}

# Provides an VPC subnet resource (private).
resource "aws_subnet" "private" {
  count = local.public_subnet_count
  cidr_block = cidrsubnet(var.vpc_cidr, 3, local.private_netnums[count.index])
  vpc_id     = aws_vpc.main.id
  availability_zone = local.target_availability_zones[count.index]
  tags = {
    Name = "Private Subnet ${count.index}"
  }
}

# Provides a resource to create a VPC NAT Gateway.
# If single AZ or egress_multi_nat_gw is false, create only 1 NAT Gateway.
resource "aws_nat_gateway" "gateway" {
  count = var.single_az || !var.egress_multi_nat_gw ? 1 : length(aws_subnet.public)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = element(aws_subnet.public[*].id, count.index % length(aws_subnet.public))
  depends_on = [aws_eip.nat]
}

# Provides a resource to create a VPC Internet Gateway.
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "Internet Gateway"
  }
}

# Provides an Elastic IP resource needed for the NAT GW.
# If single AZ or egress_multi_nat_gw is false, create only 1 EIP for the NAT Gateway.
resource "aws_eip" "nat" {
  count  = var.single_az || !var.egress_multi_nat_gw ? 1 : length(aws_subnet.public)
  domain = "vpc"
}

# Provides a resource to create an association between a route table and a subnet or a route table and an internet gateway or virtual private gateway (public).
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Provides a resource to create a VPC routing table (public).
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "Public Route Table"
  }
}

# Provides a resource to create a VPC routing table (private).
resource "aws_route_table" "private" {
  count = length(aws_subnet.private)
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "Private Route Table ${aws_subnet.private[count.index].availability_zone}"
  }
}

# Provides a resource to create a routing table entry (a route) in a VPC routing table.
# If single AZ or egress_multi_nat_gw is false, use the first NAT Gateway, else use the corresponding NAT Gateway for each subnet.
resource "aws_route" "nat_route" {
  count = length(aws_subnet.private)
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"  
  nat_gateway_id         = var.single_az || !var.egress_multi_nat_gw ? aws_nat_gateway.gateway[0].id : element(aws_nat_gateway.gateway[*].id, count.index % length(aws_nat_gateway.gateway))
}

# Provides a resource to create an association between a route table and a subnet or a route table and an internet gateway or virtual private gateway (private).
resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
