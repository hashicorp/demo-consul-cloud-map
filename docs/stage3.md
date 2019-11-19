---
layout: default
title: Stretch the Mesh from OnPrem to AWS
nav_order: 4
---

# Stretch the Mesh from OnPrem to AWS

We start refactoring the API and deploy it to AWS. However, while we know the Web UI on AWS works,
we need to figure out if the API on AWS works correctly. We stretch the mesh by creating a Consul
server on AWS and installing a Consul agent on the Web and API EC2 instances.

![Corporate datacenter and AWS with web, api, and Consul servers](images/stage3/architecture.png)

In order to maintain the connection to the onprem database, we use AWS Cloud Map to
resolve to `database.example.terraform` from the API service on AWS.

## Update API Service on AWS

Since we use AWS Cloud Map's namespace to resolve to our onprem database, we can remove the
`upstream` out of the Consul configuration for the API service.

```json
{
  "service": {
    "name": "api",
    "id":"api",
    "port": 9090,
    "checks": [
      {
       "id": "api",
       "name": "HTTP API on port 9090",
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
          "upstreams": []
        }
      }
    }  
  }
}
```

We update the environment variable for our database URI to use `database.example.terraform`.

```shell
UPSTREAM_URIS=http://database.example.terraform:9090
```
