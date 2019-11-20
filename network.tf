# Create a VPC to launch our instances into
resource "aws_vpc" "default" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true

  tags = {
    Name = "my-vpc"
  }
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name = "my-gateway"
  }
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.default.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.default.id
}

# Create a subnet to launch our instances into
resource "aws_subnet" "default" {
  count                   = length(var.private_subnets)
  vpc_id                  = aws_vpc.default.id
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = var.private_subnets[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "my-subnet-${count.index}"
  }
}

resource "aws_security_group_rule" "allow_consul" {
  type        = "ingress"
  from_port   = 8500
  to_port     = 8500
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_vpc.default.default_security_group_id
}

resource "aws_security_group_rule" "allow_consul_wan" {
  type        = "ingress"
  from_port   = 8302
  to_port     = 8302
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_vpc.default.default_security_group_id
}

resource "aws_security_group_rule" "allow_consul_wan_raft" {
  type        = "ingress"
  from_port   = 8300
  to_port     = 8300
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_vpc.default.default_security_group_id
}

resource "aws_security_group_rule" "allow_consul_mesh_gateway" {
  type        = "ingress"
  from_port   = 8443
  to_port     = 8443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_vpc.default.default_security_group_id
}

resource "aws_security_group_rule" "allow_fake_service" {
  type        = "ingress"
  from_port   = 9090
  to_port     = 9090
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_vpc.default.default_security_group_id
}

resource "aws_security_group_rule" "allow_jaeger" {
  type        = "ingress"
  from_port   = 16686
  to_port     = 16686
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_vpc.default.default_security_group_id
}

resource "aws_security_group_rule" "allow_jaeger_spans" {
  type        = "ingress"
  from_port   = 9411
  to_port     = 9411
  protocol    = "tcp"
  cidr_blocks = [var.vpc_cidr_block]

  security_group_id = aws_vpc.default.default_security_group_id
}

resource "aws_security_group_rule" "allow_envoy" {
  type        = "ingress"
  from_port   = 20000
  to_port     = 20000
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_vpc.default.default_security_group_id
}

resource "aws_security_group_rule" "allow_ssh" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_vpc.default.default_security_group_id
}