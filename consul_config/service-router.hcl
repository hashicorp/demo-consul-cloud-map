# A/B test
kind = "service-router"

name = "web"

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
      service = "web-on-aws"
    }
  },
  {
    match {
      http {
        path_prefix = "/"
      }
    }

    destination {
      service = "web"
    }
  },
]
