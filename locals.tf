locals {
  host                   = data.digitalocean_kubernetes_cluster.mtogo.endpoint
  token                  = data.digitalocean_kubernetes_cluster.mtogo.kube_config[0].token
  cluster_ca_certificate = base64decode(
    data.digitalocean_kubernetes_cluster.mtogo.kube_config[0].cluster_ca_certificate
  )
}