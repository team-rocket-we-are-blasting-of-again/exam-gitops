resource "digitalocean_kubernetes_cluster" "mtogo" {
  name    = "mtogo"
  region  = "fra1"
  version = "1.25.4-do.0"

  node_pool {
    name       = "autoscale-worker-pool"
    size       = "s-2vcpu-2gb"
    node_count = 6
  }
}

module "devops" {
  depends_on       = [time_sleep.wait_for_helm, module.production]
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

module "production" {
  depends_on                     = [time_sleep.wait_for_helm]
  source                         = "./environments/production"
  email                          = var.email
  website                        = var.website
  camunda_admin_password         = var.camunda_admin_password
  camunda_admin_user             = var.camunda_admin_user
  camunda_postgres_db            = var.camunda_postgres_db
  camunda_postgres_root_password = var.camunda_postgres_root_password
  camunda_postgres_user          = var.camunda_admin_user
  camunda_postgres_user_password = var.camunda_postgres_user_password
  gateway_password               = var.gateway_password
  gateway_postgres_db            = var.gateway_postgres_db
  gateway_postgres_user          = var.gateway_postgres_user
  gateway_postgres_user_password = var.gateway_postgres_user_password
  gateway_username               = var.gateway_username
  order_postgres_db              = var.order_postgres_db
  order_postgres_user            = var.order_postgres_user
  order_postgres_user_password   = var.order_postgres_user_password
  auth_postgres_db               = var.auth_postgres_db
  auth_postgres_user             = var.auth_postgres_user
  auth_postgres_user_password    = var.auth_postgres_user_password
  courier_postgres_db            = var.courier_postgres_db
  courier_postgres_user          = var.courier_postgres_user
  courier_postgres_user_password = var.courier_postgres_user_password
  customer_postgres_db           = var.customer_postgres_db
  customer_postgres_user         = var.customer_postgres_user
  customer_postgres_user_password = var.customer_postgres_user_password
  restaurant_postgres_db = var.restaurant_postgres_db
  restaurant_postgres_user = var.restaurant_postgres_user
  restaurant_postgres_user_password = var.restaurant_postgres_user_password
  email_password = var.email_password
}

#module "test" {
#  depends_on                     = [time_sleep.wait_for_helm]
#  source                         = "./environments/test"
#  email                          = var.email
#  website                        = var.website
#  camunda_admin_password         = var.camunda_admin_password
#  camunda_admin_user             = var.camunda_admin_user
#  camunda_postgres_db            = var.camunda_postgres_db
#  camunda_postgres_root_password = var.camunda_postgres_root_password
#  camunda_postgres_user          = var.camunda_admin_user
#  camunda_postgres_user_password = var.camunda_postgres_user_password
#  gateway_postgres_db            = var.gateway_postgres_db
#  gateway_postgres_user          = var.gateway_postgres_user
#  gateway_postgres_user_password = var.gateway_postgres_user_password
#  gateway_username               = var.gateway_username
#  gateway_password               = var.gateway_password
#}

module "domain" {
  source     = "./modules/domain"
  domain     = var.website
  subdomains = [
    "api.staging",
    "api.test",
    "api",
    "camunda.staging",
    "camunda.test",
    "camunda",
    "monitor",
  ]
  target_ip = module.production.load_balancer_ip
  ttl_sec   = 300
}
