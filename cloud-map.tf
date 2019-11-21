resource "aws_service_discovery_private_dns_namespace" "example" {
  name        = "example.terraform"
  description = "example"
  vpc         = aws_vpc.default.id
}

resource "aws_service_discovery_service" "api_on_aws" {
  name = "api-on-aws"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.example.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}