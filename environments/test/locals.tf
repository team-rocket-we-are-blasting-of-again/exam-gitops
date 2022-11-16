locals {
  namespace           = kubernetes_namespace.test.metadata.0.name
  cluster_issuer_name = format("letsencrypt-%s", local.namespace)
  secret_name         = format("certificate-%s", local.namespace)
}