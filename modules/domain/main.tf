terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

# Create a new domain
resource "digitalocean_domain" "default" {
  name       = var.domain
  ip_address = var.target_ip
}

resource "digitalocean_domain" "subdomains" {
  for_each   = var.subdomains
  name       = each.value
  ip_address = var.target_ip
}