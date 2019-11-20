kind = "service-splitter"
name = "api"
splits = [
  {
    weight = 50
    service = "api-onprem"
  },
  {
    weight  = 50
    service = "api-on-aws"
  },
]