resource "kubernetes_deployment" "notification" {
  depends_on = [kubernetes_deployment.kafka, time_sleep.wait_for_gateway]
  metadata {
    namespace = local.namespace
    name      = "notification"
    labels = {
      app = "notification"
    }
  }
  spec {
    selector {
      match_labels = {
        app = "notification"
      }
    }
    template {
      metadata {
        labels = {
          app = "notification"
        }
      }
      spec {
        container {
          name  = "notification"
          image = "tobiaszimmer/exam-notification-service:master-1.0.0-release"
          env {
            name  = "FROM_EMAIL"
            value = "tobias.zimmer@hotmail.com"
          }
          env {
            name  = "FROM_PASSWORD"
            value = var.email_password
          }
          env {
            name  = "SERVER_PORT"
            value = "8080"
          }
          env {
            name  = "KAFKA_BOOTSTRAP_SERVER"
            value = "kafka:9092"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "notification" {
  metadata {
    namespace = local.namespace
    name      = "notification"
  }
  spec {
    selector = {
      app = "notification"
    }
    port {
      port        = 8080
      target_port = "8080"
    }
  }
}

