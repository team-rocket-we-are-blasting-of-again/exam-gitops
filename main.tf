resource "digitalocean_kubernetes_cluster" "mtogo" {
  name    = "mtogo"
  region  = "fra1"
  version = "1.24.4-do.0"

  node_pool {
    name       = "autoscale-worker-pool"
    size       = "s-1vcpu-2gb"
    auto_scale = true
    min_nodes  = 1
    max_nodes  = 2
  }
}

module "devops" {
  depends_on = [time_sleep.wait_for_helm]
  source     = "./environments/devops"
  email      = var.email
  website    = var.website
}

module "staging" {
  depends_on = [time_sleep.wait_for_helm]
  source     = "./environments/staging"
  email      = var.email
  website    = var.website
}

module "production" {
  depends_on = [time_sleep.wait_for_helm]
  source     = "./environments/production"
  email      = var.email
  website    = var.website
}

module "test" {
  depends_on = [time_sleep.wait_for_helm]
  source     = "./environments/test"
  email      = var.email
  website    = var.website
}

module "domain" {
  source = "./modules/domain"
  domain = var.website
  subdomains = [
    "build",
    "api.staging",
    "api.test",
    "api",
    "camunda.staging",
    "camunda.test",
    "camunda"
  ]
  target_ip = module.devops.load_balancer_ip
  ttl_sec   = 300
}
