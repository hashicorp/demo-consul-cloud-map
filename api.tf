resource "aws_instance" "api_onprem" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer.key_name

  vpc_security_group_ids      = [aws_vpc.default.default_security_group_id]
  subnet_id                   = aws_subnet.default[0].id
  associate_public_ip_address = true

  user_data = templatefile("${path.module}/templates/api.tpl", {
    dc                         = "onprem",
    use_proxy                  = true,
    consul_cluster_addr        = aws_instance.consul_server_onprem.private_ip,
    shared_services_private_ip = aws_instance.shared_services.private_ip
    error_rate                 = 0.0
  })

  tags = {
    Name     = "API"
    Location = "OnPrem"
  }
}

resource "aws_instance" "api_aws" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer.key_name

  vpc_security_group_ids      = [aws_vpc.default.default_security_group_id]
  subnet_id                   = aws_subnet.default[1].id
  associate_public_ip_address = true

  user_data = templatefile("${path.module}/templates/api.tpl", {
    dc                         = "aws",
    use_proxy                  = false,
    consul_cluster_addr        = aws_instance.consul_server_aws.private_ip,
    shared_services_private_ip = aws_instance.shared_services.private_ip,
    error_rate                 = var.fix_api_on_aws ? 0.0 : 0.5
  })

  tags = {
    Name     = "API"
    Location = "AWS"
  }
}
