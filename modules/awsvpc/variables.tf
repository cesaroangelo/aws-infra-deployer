variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
  default     = "VPC-test1"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "single_az" {
  description = "Deploy in a single AZ if true, multiple AZs if false."
  type        = bool
  default     = true
}

variable "availability_zones" {
  description = "List of availability zones to use"
  type        = list(string)
  default     = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
}

variable "egress_multi_nat_gw" {
  description = "If true, create a NAT Gateway for each public subnet (multi-AZ); otherwise, create only one."
  type        = bool
  default     = false
}
