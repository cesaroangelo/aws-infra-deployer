# Terraform AWS VPC Module – Customizable Single/Multi-AZ VPC with NAT Gateway Support

A flexible and easy-to-use **Terraform module** to deploy a configurable **Amazon Web Services (AWS) VPC**, supporting both **single** and **multi-AZ** environments. The module provisions **public and private subnets**, **Internet Gateway**, and optionally multiple **NAT Gateways** for outbound traffic.

---

## 🚀 Features

- Provision an AWS VPC using Terraform
- Support for single or multi Availability Zone (AZ) deployments
- Automatically create public and private subnets
- Internet Gateway and NAT Gateway integration
- Support for multi-NAT Gateway strategy via variable toggle
- Custom CIDR ranges and AZ selection
- Modular and easy to integrate into existing infrastructures

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

---

## 📦 Use Cases

- Deploy AWS network infrastructure via Terraform
- Separate public and private traffic via subnets
- Enable internet access from private subnets using NAT
- Start building a multi-AZ architecture foundation

---

## 🚀 Usage
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

---

## 📍 License

Apache-2.0 License – feel free to use and adapt with attribution.

---