module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs                = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets    = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_dns_hostnames = true

  tags               = {
    Terraform        = "true"
    Environment      = "dev"
  }
}

resource "aws_security_group_rule" "allow_consul" {
  type            = "ingress"
  from_port       = 8500
  to_port         = 8500
  protocol        = "tcp"
  cidr_blocks     = ["0.0.0.0/0"]

  security_group_id = module.vpc.default_security_group_id
}

resource "aws_security_group_rule" "allow_fake_service" {
  type            = "ingress"
  from_port       = 9090
  to_port         = 9090
  protocol        = "tcp"
  cidr_blocks     = ["0.0.0.0/0"]

  security_group_id = module.vpc.default_security_group_id
}

resource "aws_security_group_rule" "allow_envoy" {
  type            = "ingress"
  from_port       = 20000
  to_port         = 20000
  protocol        = "tcp"
  cidr_blocks     = ["0.0.0.0/0"]

  security_group_id = module.vpc.default_security_group_id
}

resource "aws_security_group_rule" "allow_ssh" {
  type            = "ingress"
  from_port       = 22
  to_port         = 22
  protocol        = "tcp"
  cidr_blocks     = ["0.0.0.0/0"]

  security_group_id = module.vpc.default_security_group_id
}
