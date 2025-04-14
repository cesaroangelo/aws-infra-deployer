# AWS VPC Terraform Module

### This Terraform module creates and configures an AWS Virtual Private Cloud (VPC) with a flexible and customizable network architecture. It supports both single and multi Availability Zone (AZ) deployments, and offers options for managing egress traffic via NAT gateways.

### Key Features:
```
- VPC CIDR Block:
    1. Requires a base CIDR block of /16 to define the IP address space for the VPC.
- AZ Deployment Options:
    1. Single AZ:
       Provisions one public subnet (/24) and one private subnet (/19) within a single Availability Zone.
    2. Multi AZ:
       Creates three public subnets (/24) and three private subnets (/19), distributed across three different Availability Zones.
- Egress Configuration:
    1. Supports configurable NAT gateway strategies based on if deploying Single AZ or Multi AZ:
       Single NAT gateway (cost-effective) in case of Single AZ.
       Optional:
        a. Single NAT gateway (cost-effective) in case of Multi AZ.
        b. One NAT gateway per AZ (high availability) in case of Multi AZ.
```

### Example:
```
terraform providers
Providers required by configuration:
.
└── module.vpc
    └── provider[registry.terraform.io/hashicorp/aws]
```
```
terraform init
```
```
terraform plan
```
```
terraform apply
```