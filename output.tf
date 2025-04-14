# VPC ID
output "vpc_id" {
  value = module.vpc.vpc_id
}

# Subnets IDs
output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
  description = "IDs of all public subnets"
}
output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
  description = "IDs of all private subnets"
}

# Internet GW ID
output "internet_gateway_id" {
  value = module.vpc.internet_gateway_id
  description = "ID of the Internet Gateway"
}

# NAT GW IDs
output "nat_gateway_ids" {
  value = module.vpc.nat_gateway_ids
  description = "IDs of all NAT Gateways"
}
