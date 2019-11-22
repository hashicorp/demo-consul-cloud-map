kind = "service-resolver"

name = "api-on-aws"

redirect {
  service    = "api"
  datacenter = "aws"
}
