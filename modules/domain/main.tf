terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

resource "digitalocean_domain" "default" {
  name       = var.domain
  ip_address = var.target_ip
}

resource "digitalocean_record" "www" {
  domain = digitalocean_domain.default.id
  name   = "www"
  type   = "A"
  value  = var.target_ip
  ttl    = var.ttl_sec
}

resource "digitalocean_record" "subdomains" {
  for_each = var.subdomains
  domain   = digitalocean_domain.default.id
  name     = each.value
  type     = "A"
  value    = var.target_ip
  ttl      = var.ttl_sec
}

resource "digitalocean_record" "subdomains_www" {
  for_each = var.subdomains
  domain   = digitalocean_domain.default.id
  name     = format("www.%s", each.value)
  type     = "A"
  value    = var.target_ip
  ttl      = var.ttl_sec
}
