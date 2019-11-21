resource "aws_appmesh_mesh" "example" {
  name = "example.terraform"
}

resource "aws_appmesh_virtual_node" "api" {
  name      = "api"
  mesh_name = aws_appmesh_mesh.example.id

  spec {
    backend {
      virtual_service {
        virtual_service_name = "api.example.local"
      }
    }

    listener {
      port_mapping {
        port     = 9090
        protocol = "http"
      }

      health_check {
        protocol            = "http"
        path                = "/health"
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout_millis      = 2000
        interval_millis     = 10000
      }
    }

    service_discovery {
      aws_cloud_map {
        service_name   = "api"
        namespace_name = aws_service_discovery_private_dns_namespace.example.name
      }
    }
  }
}