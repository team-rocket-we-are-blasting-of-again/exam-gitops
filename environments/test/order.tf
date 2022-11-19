resource "kubernetes_deployment" "order" {
  depends_on = [kubernetes_deployment.camunda]
  metadata {
    namespace = local.namespace
    name      = "order"
    labels    = {
      app = "order"
    }
  }
  spec {
    selector {
      match_labels = {
        app = "order"
      }
    }
    template {
      metadata {
        labels = {
          app = "order"
        }
      }
      spec {
        container {
          name  = "order"
          image = "tobiaszimmer/exam-order-service:orderCrud-0.0.1-snapshot"
          env {
            name  = "SPRING_DATASOURCE_URL"
            value = "jdbc:postgresql://postgres-order-postgresql:5432/orders"
          }
          env {
            name  = "SPRING_DATASOURCE_USERNAME"
            value = "orders"
          }
          env {
            name  = "SPRING_DATASOURCE_PASSWORD"
            value = "1234"
          }
          env {
            name  = "CAMUNDA_BPM_CLIENT_BASE_URL"
            value = "http://camunda:8080/engine-rest"
          }
        }
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "order_volume" {
  metadata {
    name      = "postgresql-order-claim"
    namespace = local.namespace
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "3Gi"
      }
    }
  }
}

resource "kubernetes_service" "order" {
  metadata {
    namespace = local.namespace
    name = "order"
  }
  spec {
    selector = {
      app = "order"
    }
    port {
      port = 8081
      target_port = "8081"
    }
  }
}

resource "helm_release" "camunda_postgres" {
  chart      = "postgresql"
  repository = "https://charts.bitnami.com/bitnami"
  name       = "postgres-order"
  namespace  = local.namespace

  set {
    name  = "primary.persistence.enabled"
    value = "true"
  }
  set {
    name  = "primary.persistence.existingClaim"
    value = kubernetes_persistent_volume_claim.order_volume.metadata.0.name
  }
  set {
    name  = "auth.enablePostgresUser"
    value = "false"
  }
  set {
    name  = "auth.username"
    value = "orders"
  }
  set {
    name  = "auth.password"
    value = "1234"
  }
  set {
    name  = "auth.database"
    value = "orders"
  }
  set {
    name  = "architecture"
    value = "standard"
  }
  set {
    name  = "primary.priorityClassName"
    value = local.priority
  }
  set {
    name  = "primary.persistence.size"
    value = "3Gi"
  }
}
