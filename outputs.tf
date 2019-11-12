output "consul_server" {
  value = aws_instance.consul_server.public_ip
}

output "shared_services" {
  value = aws_instance.shared_services.public_ip
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
  sensitive = true
  value     = tls_private_key.deployer.private_key_pem
}

output "namespace_id" {
  value = aws_service_discovery_private_dns_namespace.example.id
}