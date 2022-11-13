locals {
  namespace           = kubernetes_namespace.devops.metadata.name
  cluster_issuer_name = format("letsencrypt-%s", local.namespace)
  secret_name         = format("certificate-%s", local.namespace)
}