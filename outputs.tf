output "consul_server" {
  value = aws_instance.consul_server.public_ip
}
