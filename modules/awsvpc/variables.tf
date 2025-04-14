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

variable "instance_ami" {
  description = "AMI ID for the EC2 instance"
  type        = string
  default     = "ami-0d52744d6551d851e"  # Amazon Linux 2 AMI in eu-central-1
}

variable "instance_type" {
  description = "Instance type for the EC2 instance"
  type        = string
  default     = "t2.micro"
}

variable "instance_name" {
  description = "Name tag for the EC2 instance"
  type        = string
  default     = "test-instance"
}

variable "instance_key_name" {
  description = "Name of the SSH key pair to use for the instance"
  type        = string
  default     = ""
}
