# Consul Service Mesh

is a distributed networking layer to connect, secure and observe services across AWS and corporate datacenter.

Here, we'll demonstrate how we can use Consul Service Mesh to automate and scale service networking and security
within a corporate datacenter and into AWS, using AWS Cloud Map.

## Pre-Requisites

- AWS Account
- [Terraform 0.12+](https://www.terraform.io/downloads.html)
- [Terraform Cloud](https://app.terraform.io/)

## Premise

Our organization has been in the process of refactoring select applications and hosting them into AWS.
We have the following general architectural approach:

- Minimize downtime due to refactor during migration.
- Use an AWS managed service, when possible.

We decided to start on a particularly challenging 3-tier application in our datacenter, complete with
web, API, and database.

1. We cannot migrate web since it behaves as a thick client application and our
   users would be disrupted by a new UI without proper communication and testing.
1. We cannot migrate database in order to better assess the data and PII stored on it.

As a result, we decide to migrate the API first.
