kind = "service-splitter"
name = "api"
splits = [
  {
    weight = 100
    service = "api-onprem"
  },
  {
    weight  = 0
    service = "api-on-aws"
  },
]