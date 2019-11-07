data "template_file" "consul_server" {
  template = file("${path.module}/templates/consul-server.tpl")
}

# Render a multi-part cloud-init config making use of the part
# above, and other source files
data "template_cloudinit_config" "consul_server_config" {
  gzip          = true
  base64_encode = true

  # Main cloud-config configuration file.
  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"
    content      = data.template_file.consul_server.rendered
  }
}

resource "aws_instance" "consul_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_default_vpc.default.default_security_group_id]
  subnet_id     = aws_default_subnet.default_az1.id
  associate_public_ip_address = true

  user_data_base64 = data.template_cloudinit_config.consul_server_config.rendered

  tags = {
    Name = "Consul_Server"
  }
}
