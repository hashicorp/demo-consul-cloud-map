variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

data "aws_region" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

variable "private_subnets" {
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}