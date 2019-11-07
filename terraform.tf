terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "niccorp"

    workspaces {
      name = "demo-consul-cloud-map"
    }
  }
}

resource "tls_private_key" "deployer" {
  algorithm   = "RSA"
  rsa_bits    = "4096"
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = tls_private_key.deployer.public_key_openssh 
}
