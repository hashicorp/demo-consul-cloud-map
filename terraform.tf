terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "niccorp"

    workspaces {
      name = "demo-consul-cloud-map"
    }
  }
}
