resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_default_subnet" "default_az1" {
  availability_zone = "us-east-1a"
  vpc_id            = aws_default_vpc.default.id

  tags = {
    Name = "Default subnet for us-east-1a"
  }
}
