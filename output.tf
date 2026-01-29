# AWS Region
output "aws_region" {
  value       = var.aws_region
  description = "AWS region where all resources are deployed"
}

# VPC ID
output "vpc_id" {
  value = module.vpc.vpc_id
}

# Subnets IDs
output "public_subnet_ids" {
  value       = module.vpc.public_subnet_ids
  description = "IDs of all public subnets"
}
output "private_subnet_ids" {
  value       = module.vpc.private_subnet_ids
  description = "IDs of all private subnets"
}

# Internet GW ID
output "internet_gateway_id" {
  value       = module.vpc.internet_gateway_id
  description = "ID of the Internet Gateway"
}

# NAT GW IDs
output "nat_gateway_ids" {
  value       = module.vpc.nat_gateway_ids
  description = "IDs of all NAT Gateways"
}

# EKS Cluster
output "eks_cluster_name" {
  value       = module.eks.cluster_name
  description = "Name of the EKS cluster"
}

output "eks_cluster_endpoint" {
  value       = module.eks.cluster_endpoint
  description = "Endpoint URL for the EKS API server"
}

output "eks_cluster_certificate_authority_data" {
  value       = module.eks.cluster_certificate_authority_data
  description = "Base64 encoded CA certificate for the EKS cluster"
}

output "eks_oidc_provider_arn" {
  value       = module.eks.oidc_provider_arn
  description = "ARN of the EKS OIDC provider"
}
