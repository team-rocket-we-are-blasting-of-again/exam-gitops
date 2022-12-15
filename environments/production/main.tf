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
    helm = {
      source  = "hashicorp/helm"
      version = "2.6.0"
    }
  }
}

resource "kubernetes_namespace" "production" {
  metadata {
    name = "production"
  }
}

resource "kubernetes_priority_class" "priority" {
  value = 4
  metadata {
    name = "production"
  }
  global_default = false
  description    = "This priority class should be used for production environment only."
}

# Utility to make sure that the gateway is started
resource "time_sleep" "wait_for_gateway" {
  depends_on = [
    kubernetes_deployment.gateway
  ]
  create_duration = "10s"
}
