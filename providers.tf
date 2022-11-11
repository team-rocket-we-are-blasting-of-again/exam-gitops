terraform {
  backend "remote" {
    organization = "team-rocket"
    hostname     = "app.terraform.io"
    workspaces {
      name = "team-rocket"
    }
  }
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = var.do_token
}
