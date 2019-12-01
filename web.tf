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

resource "aws_instance" "web_onprem" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer.key_name

  vpc_security_group_ids      = [aws_vpc.default.default_security_group_id]
  subnet_id                   = aws_subnet.default[0].id
  associate_public_ip_address = true

  user_data = templatefile("${path.module}/templates/web.tpl", {
    dc                         = "onprem",
    use_proxy                  = var.use_consul_proxy_for_api,
    consul_cluster_addr        = aws_instance.consul_server_onprem.private_ip,
    shared_services_private_ip = aws_instance.shared_services.private_ip
    api_endpoint               = "api-on-aws.service.consul"
  })

  tags = {
    Name     = "Web"
    Location = "OnPrem"
  }
}

resource "aws_instance" "web_aws" {
  count         = var.enable_web_on_aws ? 1 : 0
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer.key_name

  vpc_security_group_ids      = [aws_vpc.default.default_security_group_id]
  subnet_id                   = aws_subnet.default[1].id
  associate_public_ip_address = true

  user_data = templatefile("${path.module}/templates/web.tpl", {
    dc                         = "aws",
    use_proxy                  = false,
    consul_cluster_addr        = aws_instance.consul_server_aws.private_ip,
    shared_services_private_ip = aws_instance.shared_services.private_ip,
    api_endpoint               = "api-on-aws.example.terraform"
  })

  tags = {
    Name     = "Web"
    Location = "AWS"
  }
}