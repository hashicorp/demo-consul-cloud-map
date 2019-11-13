# A/B test
kind = "service-router"
name = "api"
routes = [
  {
    match {
      http {
        header = [
          {
            name  = "location"
            exact = "aws"
          },
        ]
      }
    }

    destination {
      service = "api"
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
      service_subset = "v2"
    }
  },
]