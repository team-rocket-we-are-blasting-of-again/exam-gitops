resource "helm_release" "loki-stack" {
  repository = "https://grafana.github.io/helm-charts"
  chart = "loki-stack"
  name  = "loki-stack"
  values = [
    file("${path.module}/config/loki-stack-values.yaml")
  ]
  namespace = local.namespace
}

resource "kubernetes_persistent_volume_claim" "prometheus_volume" {
  metadata {
    name      = "postgresql-prometheus-claim"
    namespace = local.namespace
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "2Gi"
      }
    }
  }
}

resource "kubernetes_deployment" "prometheus" {
  metadata {
    namespace = local.namespace
    name      = "prometheus"
    labels = {
      app = "prometheus"
    }
  }
  spec {
    selector {
      match_labels = {
        app = "prometheus"
      }
    }
    template {
      metadata {
        labels = {
          app = "prometheus"
        }
      }
      spec {
        priority_class_name = local.priority
        security_context {
          fs_group = "104"
        }
        container {
          name  = "prometheus"
          image = "tobiaszimmer/exam-service-monitoring:prometheus-19-34-2022-11-29"
          volume_mount {
            name       = "data"
            mount_path = "/prometheus"
          }
          env {
            name  = "PROMETHEUS_HOSTS"
            value = "gateway:8080"
          }
          env {
            name  = "USERNAME"
            value = var.gateway_username
          }
          env {
            name  = "PASSWORD"
            value = var.gateway_password
          }
        }
        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.prometheus_volume.metadata.0.name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "prometheus" {
  metadata {
    namespace = local.namespace
    name      = "prometheus"
  }
  spec {
    selector = {
      app = "prometheus"
    }
    port {
      port        = 9090
      target_port = "9090"
    }
  }
}

resource "kubernetes_persistent_volume_claim" "grafana_volume" {
  metadata {
    name      = "postgresql-grafana-claim"
    namespace = local.namespace
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "2Gi"
      }
    }
  }
}

resource "kubernetes_deployment" "grafana" {
  metadata {
    namespace = local.namespace
    name      = "grafana"
    labels = {
      app = "grafana"
    }
  }
  spec {
    selector {
      match_labels = {
        app = "grafana"
      }
    }
    template {
      metadata {
        labels = {
          app = "grafana"
        }
      }
      spec {
        priority_class_name = local.priority
        security_context {
          fs_group = "104"
        }
        container {
          name  = "grafana"
          image = "tobiaszimmer/exam-service-monitoring:grafana-19-34-2022-11-29"
          volume_mount {
            name       = "data"
            mount_path = "/var/lib/grafana"
          }
          env {
            name  = "GF_SECURITY_ADMIN_USER"
            value = var.grafana_username
          }
          env {
            name  = "GF_SECURITY_ADMIN_PASSWORD"
            value = var.grafana_password
          }
        }
        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.grafana_volume.metadata.0.name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "grafana" {
  metadata {
    namespace = local.namespace
    name      = "grafana"
  }
  spec {
    selector = {
      app = "grafana"
    }
    port {
      port        = 3000
      target_port = "3000"
    }
  }
}
