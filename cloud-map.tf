resource "aws_service_discovery_private_dns_namespace" "example" {
  name        = "example.terraform"
  description = "example"
  vpc         = aws_vpc.default.id
}
