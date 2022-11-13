terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.13.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
  }
}

resource "kubernetes_namespace" "devops" {
  metadata {
    name = local.namespace
  }
}

resource "time_sleep" "prerequisites" {
  depends_on = [
    kubernetes_namespace.devops
  ]
  create_duration = "10s"
}
