resource "aws_service_discovery_public_dns_namespace" "example" {
  name        = "example.terraform"
  description = "example"
  #vpc         = aws_default_vpc.default.id
}
