# A/B test
kind = "service-router"
name = "api"
routes = [
  {
    match {
      http {
        header = [
          {
            name  = "datacenter"
            exact = "aws"
          },
        ]
      }
    }

    destination {
      service = "api-on-aws"
    }

  },
  {
    match {
      http {
        path_prefix = "/"
      }
    }

    destination {
      service        = "api"
    }
  },
]