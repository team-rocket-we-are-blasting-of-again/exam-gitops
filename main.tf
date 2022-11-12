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
