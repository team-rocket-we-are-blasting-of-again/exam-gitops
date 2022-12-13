resource "kubernetes_deployment" "payment" {
  depends_on = [kubernetes_deployment.camunda]
  metadata {
    namespace = local.namespace
    name      = "payment"
    labels = {
      app = "payment"
    }
  }
  spec {
    selector {
      match_labels = {
        app = "payment"
      }
    }
    template {
      metadata {
        labels = {
          app = "payment"
        }
      }
      spec {
        container {
          name  = "payment"
          image = "tobiaszimmer/exam-payment-service:main-1.0.0-release"
          env {
            name  = "CASE_MANAGEMENT_CAMUNDA_BASE_URL"
            value = "http://camunda:8080/engine-rest"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "payment" {
  metadata {
    namespace = local.namespace
    name      = "payment"
  }
  spec {
    selector = {
      app = "payment"
    }
    port {
      port        = 9081
      target_port = "9081"
    }
  }
}
