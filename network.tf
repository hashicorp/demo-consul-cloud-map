resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_security_group_rule" "allow_consul" {
  type            = "ingress"
  from_port       = 8500
  to_port         = 8500
  protocol        = "tcp"
  cidr_blocks     = ["0.0.0.0/0"]

  security_group_id = aws_default_vpc.default.default_security_group_id
}

resource "aws_security_group_rule" "allow_fake_service" {
  type            = "ingress"
  from_port       = 9090
  to_port         = 9090
  protocol        = "tcp"
  cidr_blocks     = ["0.0.0.0/0"]

  security_group_id = aws_default_vpc.default.default_security_group_id
}

resource "aws_security_group_rule" "allow_ssh" {
  type            = "ingress"
  from_port       = 22
  to_port         = 22
  protocol        = "tcp"
  cidr_blocks     = ["0.0.0.0/0"]

  security_group_id = aws_default_vpc.default.default_security_group_id
}

resource "aws_default_subnet" "default_az1" {
  availability_zone = "us-east-1a"

  tags = {
    Name = "Default subnet for us-east-1a"
  }
}
