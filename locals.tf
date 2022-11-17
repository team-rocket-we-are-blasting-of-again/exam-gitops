locals {
  host                   = digitalocean_kubernetes_cluster.mtogo.endpoint
  token                  = digitalocean_kubernetes_cluster.mtogo.kube_config[0].token
  cluster_ca_certificate = base64decode(
    digitalocean_kubernetes_cluster.mtogo.kube_config[0].cluster_ca_certificate
  )
}