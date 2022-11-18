resource "digitalocean_kubernetes_cluster" "mtogo" {
  name    = "mtogo"
  region  = "fra1"
  version = "1.24.4-do.0"

  node_pool {
    name       = "autoscale-worker-pool"
    size       = "s-2vcpu-2gb"
    node_count = 3
#    auto_scale = true
#    min_nodes  = 1
#    max_nodes  = 3
  }
}

# module "devops" {
#   depends_on = [time_sleep.wait_for_helm]
#   source     = "./environments/devops"
#   email      = var.email
#   website    = var.website
# }

module "staging" {
  depends_on                     = [time_sleep.wait_for_helm]
  source                         = "./environments/staging"
  email                          = var.email
  website                        = var.website
  camunda_admin_password         = var.camunda_admin_password
  camunda_admin_user             = var.camunda_admin_user
  camunda_postgres_db            = var.camunda_postgres_db
  camunda_postgres_root_password = var.camunda_postgres_root_password
  camunda_postgres_user          = var.camunda_admin_user
  camunda_postgres_user_password = var.camunda_postgres_user_password
}

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
  target_ip = module.staging.load_balancer_ip
  ttl_sec   = 300
}
