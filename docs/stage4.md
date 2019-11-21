---
layout: default
title: Gradually Cutover to API on AWS
nav_order: 5
---

# Gradually Cutover to API on AWS

We test the Web UI on AWS and it works succesfully. We need to test the API on AWS
but we want to ensure it works with live traffic. In order to test API on AWS in production,
we want to selectively divert traffic to the API on AWS, while allowing all production traffic
to default to the API onprem.

![Direct all user traffic to Web UI on AWS and canary traffic between AWS and onprem](images/stage4/architecture.png)

## Add Service Resolvers

First, we want to configure requests to `api-onprem` goes to the API onprem and `api-on-aws` goes to API on AWS.

```hcl
kind = "service-resolver"
name = "api-on-aws"
redirect {
  service    = "api"
  datacenter = "aws"
}
```

```hcl
kind = "service-resolver"
name = "api-onprem"
redirect {
  service    = "api"
  datacenter = "onprem"
}
```

We apply these configurations to our Consul server in AWS.

```shell
CONSUL_HTTP_ADDR=http://$(shell terraform output consul_server_aws):8500 consul config write consul_config/service-resolver-onprem.hcl
CONSUL_HTTP_ADDR=http://$(shell terraform output consul_server_aws):8500 consul config write consul_config/service-resolver-aws.hcl
```

Next, we want to direct all traffic to the API onprem. As the legacy application, we know the requests work. We
configure a Consul service-splitter to divert the traffic.

```hcl
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
```

When we apply the configuration to Consul and re-deploy the Web UI on AWS to use the proxy,
we can see that it references the API onprem.

```shell
CONSUL_HTTP_ADDR=http://$(shell terraform output consul_server_aws):8500 consul config write consul_config/service-splitter.hcl
```

