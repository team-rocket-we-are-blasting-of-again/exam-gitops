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
    name = "devops"
  }
}

resource "kubernetes_priority_class" "priority" {
  value = 2
  metadata {
    name = "devops"
  }
  global_default = false
  description = "This priority class should be used for DevOps environment only."
}
