locals {
  namespace           = kubernetes_namespace.devops.metadata.0.name
  cluster_issuer_name = format("letsencrypt-%s", local.namespace)
  secret_name         = format("certificate-%s", local.namespace)
  priority            = kubernetes_priority_class.priority.metadata.0.name
}