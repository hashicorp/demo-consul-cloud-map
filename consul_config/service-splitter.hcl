kind = "service-splitter"

name = "api"

splits = [
  {
    weight  = 0
    service = "api"
  },
  {
    weight  = 100
    service = "api-on-aws"
  },
]
