output "consul_server_onprem" {
  value = aws_eip.consul_server_onprem.public_ip
}

output "consul_server_aws" {
  value = aws_eip.consul_server_aws.public_ip
}

output "shared_services" {
  value = aws_instance.shared_services.public_ip
}

output "web_onprem" {
  value = aws_instance.web_onprem.public_ip
}

output "web_aws" {
  value = length(aws_instance.web_aws) > 1 ? aws_instance.web_aws[0].public_ip : ""
}

output "api_onprem" {
  value = aws_instance.api_onprem.public_ip
}

output "api_aws" {
  value = aws_instance.api_aws.public_ip
}

output "database" {
  value = aws_instance.database.public_ip
}

output "tester" {
  value = aws_instance.tester.public_ip
}

output "private_key" {
  sensitive = true
  value     = tls_private_key.deployer.private_key_pem
}

output "namespace_id" {
  value = aws_service_discovery_private_dns_namespace.example.id
}

output "service_id" {
  value = aws_service_discovery_service.api_on_aws.id
}

output "instance_id" {
  sensitive = true
  value     = aws_instance.api_aws.id
}