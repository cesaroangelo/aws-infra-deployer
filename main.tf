# Creates a AWS Virtual Private Cloud (VPC) using a custom module located in ./modules/awsvpc.
# The VPC will have the CIDR block 10.0.0.0/16 and will be deployed across 
# multiple Availability Zones if single_az is set to false or single Availability Zone if single_az is set to true.

module "vpc" {
  vpc_name        = "MyVPC1"
  source          = "./modules/awsvpc"
  vpc_cidr        = "10.0.0.0/16"

  ### sinble_az = true or false
  single_az       = true

  ### Ignored if single_az is true
  egress_multi_nat_gw = false  
}
