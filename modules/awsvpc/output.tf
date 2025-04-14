output "vpc_id" {
  description = "The ID of the VPC."
  value = aws_vpc.main.id
}

output "subnet_ids" {
  description = "The IDs of the public and private subnets."
  value = {
    public  = aws_subnet.public[*].id
    private = aws_subnet.private[*].id
  }
}

# Subnets IDs
output "public_subnet_ids" {
  value = aws_subnet.public[*].id
  description = "IDs of all public subnets"
}
output "private_subnet_ids" {
  value = aws_subnet.private[*].id
  description = "IDs of all private subnets"
}

# Internet GW ID
output "internet_gateway_id" {
  value = aws_internet_gateway.gw.id
  description = "ID of the Internet Gateway"
}

# NAT GW IDs
output "nat_gateway_ids" {
  value = aws_nat_gateway.gateway[*].id
  description = "IDs of all NAT Gateways"
}
