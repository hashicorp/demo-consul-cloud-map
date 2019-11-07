resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_security_group_rule" "allow_consul" {
  type            = "ingress"
  from_port       = 8500
  to_port         = 8500
  protocol        = "http"
  cidr_blocks     = ["0.0.0.0/0"]

  security_group_id = aws_default_vpc.default.default_security_group_id
}
