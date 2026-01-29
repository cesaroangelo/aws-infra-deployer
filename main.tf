# Creates a AWS Virtual Private Cloud (VPC) using a custom module located in ./modules/awsvpc.
# The VPC will have the CIDR block 10.0.0.0/16 and will be deployed across
# multiple Availability Zones if single_az is set to false or single Availability Zone if single_az is set to true.

variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "eu-central-1"
}

provider "aws" {
  region = var.aws_region
}

module "vpc" {
  vpc_name = "MyVPC1"
  source   = "./modules/awsvpc"
  vpc_cidr = "10.0.0.0/16"

  ### single_az = true or false
  single_az = false

  ### Ignored if single_az is true
  egress_multi_nat_gw = true
}

# Creates an EKS dev/test cluster using a custom module located in ./modules/eks.
# The cluster is deployed into the private subnets of the VPC created above.
module "eks" {
  source             = "./modules/eks"
  cluster_name       = "dev-eks-cluster"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
}
