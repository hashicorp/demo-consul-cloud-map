kind = "service-resolver"

name = "web-on-aws"

redirect {
  service    = "web"
  datacenter = "aws"
}
