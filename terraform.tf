terraform {
  backend "remote" {
    organization = "hashicorp-team-da-beta"

    workspaces {
      name = "demo-consul-cloud-map"
    }
  }
}

resource "tls_private_key" "deployer" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer"
  public_key = tls_private_key.deployer.public_key_openssh
}
