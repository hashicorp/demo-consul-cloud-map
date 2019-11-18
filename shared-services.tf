resource "aws_instance" "shared_services" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer.key_name

  vpc_security_group_ids      = [aws_vpc.default.default_security_group_id]
  subnet_id                   = aws_subnet.default[2].id
  associate_public_ip_address = true

  user_data = templatefile("${path.module}/templates/shared-services.tpl", {})

  tags = {
    Name = "Shared Services"
  }
}