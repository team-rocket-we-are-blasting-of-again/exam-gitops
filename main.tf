resource "digitalocean_kubernetes_cluster" "mtogo" {
  name    = "mtogo"
  region  = "fra1"
  version = "1.24.4-do.0"

  node_pool {
    name       = "autoscale-worker-pool"
    size       = "s-2vcpu-2gb"
    node_count = 2
    #    auto_scale = true
    #    min_nodes  = 1
    #    max_nodes  = 3
  }
}

module "devops" {
  depends_on       = [time_sleep.wait_for_helm]
  source           = "./environments/devops"
  email            = var.email
  website          = var.website
  gateway_username = var.gateway_username
  gateway_password = var.gateway_password
  grafana_username = var.grafana_username
  grafana_password = var.grafana_password
}

# module "staging" {
#   depends_on                     = [time_sleep.wait_for_helm]
#   source                         = "./environments/staging"
#   email                          = var.email
#   website                        = var.website
#   camunda_admin_password         = var.camunda_admin_password
#   camunda_admin_user             = var.camunda_admin_user
#   camunda_postgres_db            = var.camunda_postgres_db
#   camunda_postgres_root_password = var.camunda_postgres_root_password
#   camunda_postgres_user          = var.camunda_admin_user
#   camunda_postgres_user_password = var.camunda_postgres_user_password
# }

# module "production" {
#   depends_on                     = [time_sleep.wait_for_helm]
#   source                         = "./environments/production"
#   email                          = var.email
#   website                        = var.website
#   camunda_admin_password         = var.camunda_admin_password
#   camunda_admin_user             = var.camunda_admin_user
#   camunda_postgres_db            = var.camunda_postgres_db
#   camunda_postgres_root_password = var.camunda_postgres_root_password
#   camunda_postgres_user          = var.camunda_admin_user
#   camunda_postgres_user_password = var.camunda_postgres_user_password
# }

module "test" {
  depends_on                     = [time_sleep.wait_for_helm]
  source                         = "./environments/test"
  email                          = var.email
  website                        = var.website
  camunda_admin_password         = var.camunda_admin_password
  camunda_admin_user             = var.camunda_admin_user
  camunda_postgres_db            = var.camunda_postgres_db
  camunda_postgres_root_password = var.camunda_postgres_root_password
  camunda_postgres_user          = var.camunda_admin_user
  camunda_postgres_user_password = var.camunda_postgres_user_password
  gateway_postgres_db            = var.gateway_postgres_db
  gateway_postgres_user          = var.gateway_postgres_user
  gateway_postgres_user_password = var.gateway_postgres_user_password
  gateway_username               = var.gateway_username
  gateway_password               = var.gateway_password
}

module "domain" {
  source = "./modules/domain"
  domain = var.website
  subdomains = [
    "api.staging",
    "api.test",
    "api",
    "camunda.staging",
    "camunda.test",
    "camunda",
    "monitor",
  ]
  target_ip = module.test.load_balancer_ip
  ttl_sec   = 300
}
