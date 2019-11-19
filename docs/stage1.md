---
layout: default
title: Adding Service Mesh to On-Prem
nav_order: 2
---

# Adding Service Mesh to On-Prem

We have an 3-tier service with web, application, and database tiers. To make it easier to control the services,
we've added Consul service mesh within the datacenter.

![A corporate datacenter featuring web, api, and database servers with Consul and Jaeger.](images/stage1/architecture.png)

When we access the Web UI at `open http://$(terraform output web_onprem):9090/ui`, we will see the web UI
connecting to the API on `http://localhost:9092` and the database at `http://localhost:9091`.

![The Web UI shows a connection to API on localhost:9092 and database on localhost:9091.](images/stage1/webui.png)

This is because each service as there is a Consul proxy running on each server. As long as the outbound request matches the address and port we bound to the upstream service, we can simply use the address and port on `localhost`. We do not have to program the static IP or load-balanced endpoint for each tier.

```json
{
  "service": {
    "name": "web",
    "id":"web",
    "port": 9090,
    "checks": [
      {
       "id": "web",
       "name": "Web on port 9090",
       "http": "http://localhost:9090/health",
       "tls_skip_verify": false,
       "method": "GET",
       "interval": "10s",
       "timeout": "1s"
      }
    ],
    "connect": { 
      "sidecar_service": {
        "port": 20000,
        "proxy": {
          "upstreams": [
            {
              "destination_name": "api",
              "local_bind_address": "127.0.0.1",
              "local_bind_port": 9092
            }
          ]
        }
      }
    }  
  }
}
```

We built the Web UI to show the request chain. If we do not have the Web UI, we direct
onprem tracing to Jaeger to visualize the requests from the application.
Note that the `call_upstream` metadata shows the Consul proxy endpoints.

![Jaeger interface with request traces showing localhost:9092 for API calls and localhost:9091 for database calls](images/stage1/tracing.png)