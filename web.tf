data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "template_file" "web" {
  template = file("${path.module}/templates/web.tpl")
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  
  subnet_id     = aws_default_subnet.default_az1.id
  vpc_security_group_ids = [aws_default_vpc.default.default_security_group_id]

  user_data = data.template_file.web.rendered

  tags = {
    Name = "HelloWorld"
  }
}
