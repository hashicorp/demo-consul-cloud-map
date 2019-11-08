data "template_file" "payments" {
  template = file("${path.module}/templates/payments.tpl")

  vars = {
    consul_cluster_addr =  aws_instance.consul_server.private_ip
  }
}

resource "aws_instance" "payments" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name = aws_key_pair.deployer.key_name

  vpc_security_group_ids = [aws_default_vpc.default.default_security_group_id]
  subnet_id     = aws_default_subnet.default_az1.id
  associate_public_ip_address = true

  user_data = data.template_file.api.rendered

  tags = {
    Name = "Consul_Server"
  }
}