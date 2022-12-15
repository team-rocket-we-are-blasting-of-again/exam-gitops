resource "kubernetes_deployment" "order" {
  depends_on = [time_sleep.wait_for_gateway, kubernetes_deployment.camunda, kubernetes_deployment.kafka]
  metadata {
    namespace = local.namespace
    name      = "order"
    labels = {
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
          image = "tobiaszimmer/exam-order-service:master-1.0.0-release"
          env {
            name  = "SPRING_DATASOURCE_URL"
            value = format("jdbc:postgresql://postgres-order-postgresql:5432/%s", var.order_postgres_db)
          }
          env {
            name  = "SPRING_DATASOURCE_USERNAME"
            value = var.order_postgres_user
          }
          env {
            name  = "SPRING_DATASOURCE_PASSWORD"
            value = var.order_postgres_user_password
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
        storage = "1Gi"
      }
    }
  }
}

resource "kubernetes_service" "order" {
  metadata {
    namespace = local.namespace
    name      = "order"
  }
  spec {
    selector = {
      app = "order"
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
    value = "1Gi"
  }
}
