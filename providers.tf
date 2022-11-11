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
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.13.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.6.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
  }
}

# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = var.do_token
}

provider "kubernetes" {
  host                   = local.host
  token                  = local.token
  cluster_ca_certificate = local.cluster_ca_certificate
}

provider "helm" {
  kubernetes {
    host                   = local.host
    token                  = local.token
    cluster_ca_certificate = local.cluster_ca_certificate
  }
}

provider "kubectl" {
  host                   = local.host
  token                  = local.token
  cluster_ca_certificate = local.cluster_ca_certificate
  load_config_file       = false
}