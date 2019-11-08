output "consul_server" {
  value = aws_instance.consul_server.public_ip
}

output "web" {
  value = aws_instance.web.public_ip
}

output "api" {
  value = aws_instance.api.public_ip
}

output "payments" {
  value = aws_instance.payments.public_ip
}

output "private_key" {
  value = tls_private_key.deployer.private_key_pem
}
