resource "aws_instance" "consul_server_aws" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer.key_name

  vpc_security_group_ids      = [aws_vpc.default.default_security_group_id]
  subnet_id                   = aws_subnet.default[1].id
  associate_public_ip_address = true

  user_data = templatefile("${path.module}/templates/consul-server.tpl", { namespace_id = "", aws_region = data.aws_region.current.name, dc = "aws" })

  iam_instance_profile = aws_iam_instance_profile.consul_server.name

  tags = {
    Name       = "Consul"
    Datacenter = "AWS"
  }
}
