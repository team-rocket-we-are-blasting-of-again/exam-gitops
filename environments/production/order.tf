resource "kubernetes_deployment" "order" {
  depends_on = [kubernetes_deployment.gateway, kubernetes_deployment.camunda]
  metadata {
    namespace = local.namespace
    name      = "order-service"
    labels = {
      app = "order-service"
    }
  }
  spec {
    selector {
      match_labels = {
        app = "order-service"
      }
    }
    template {
      metadata {
        labels = {
          app = "order-service"
        }
      }
      spec {
        container {
          name  = "order"
          image = "tobiaszimmer/exam-order-service:master-1.0.0-release"
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
            value = "something1234"
          }
          env {
            name  = "CASE_MANAGEMENT_CAMUNDA_BASE_URL"
            value = "http://camunda:8080/engine-rest"
          }
          env {
            name  = "CAMUNDA_ENGINE_REST"
            value = "http://camunda:8080/engine-rest/"
          }
          env {
            name  = "KAFKA_BOOTSTRAP_SERVERS"
            value = "kafka:9092"
          }
          env {
            name  = "GATEWAY_USERNAME"
            value = var.gateway_username
          }
          env {
            name  = "GATEWAY_PASSWORD"
            value = var.gateway_password
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
    name      = "order-service"
  }
  spec {
    selector = {
      app = "order-service"
    }
    port {
      port        = 8081
      target_port = "8081"
    }
  }
}

resource "helm_release" "order_postgres" {
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
    value = "something1234"
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

resource "helm_release" "order_postgres" {
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
    value = var.order_postgres_user
  }
  set {
    name  = "auth.password"
    value = var.order_postgres_user_password
  }
  set {
    name  = "auth.database"
    value = var.order_postgres_db
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
