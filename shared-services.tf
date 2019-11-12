data "template_file" "shared_services" {
  template = file("${path.module}/templates/shared-services.tpl")
}

resource "aws_instance" "shared_services" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer.key_name

  vpc_security_group_ids      = [aws_vpc.default.default_security_group_id]
  subnet_id                   = aws_subnet.default[0].id
  associate_public_ip_address = true

  user_data = data.template_file.shared_services.rendered

  tags = {
    Name = "Shared_Services"
  }
}

resource "aws_route53_record" "shared_services" {
  zone_id = aws_service_discovery_private_dns_namespace.example.hosted_zone
  name    = "shared.${aws_service_discovery_private_dns_namespace.example.name}"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.shared_services.private_ip]
}