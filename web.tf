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
  key_name = aws_key_pair.deployer.key_name

  vpc_security_group_ids = [module.vpc.default_security_group_id]
  subnet_id     = module.vpc.private_subnets[0]
  associate_public_ip_address = true

  user_data = data.template_file.web.rendered

  tags = {
    Name = "Web"
  }
}
