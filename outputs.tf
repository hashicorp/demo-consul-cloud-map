output "consul_server" {
  value = aws_instance.consul_server.public_ip
}

output "private_key" {
  value = tls_private_key.deployer.private_key_pem
}
