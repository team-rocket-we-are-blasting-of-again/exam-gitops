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
        container {
          name  = "prometheus"
          image = "tobiaszimmer/exam-service-monitoring:prometheus-10-58-2022-11-27"
          env {
            name = "PROMETHEUS_HOSTS"
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
        container {
          name  = "grafana"
          image = "tobiaszimmer/exam-service-monitoring:prometheus-10-58-2022-11-27"
          env {
            name = "GF_SECURITY_ADMIN_USER"
            value = "admin"
          }
          env {
            name  = "GF_SECURITY_ADMIN_PASSWORD"
            value = "admin"
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
