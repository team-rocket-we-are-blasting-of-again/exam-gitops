# TODO: depends on auth
resource "kubernetes_deployment" "restaurant" {
  depends_on = [kubernetes_deployment.gateway, kubernetes_deployment.camunda, kubernetes_deployment.kafka]
  metadata {
    namespace = local.namespace
    name      = "restaurant"
    labels    = {
      app = "restaurant"
    }
  }
  spec {
    selector {
      match_labels = {
        app = "restaurant"
      }
    }
    template {
      metadata {
        labels = {
          app = "restaurant"
        }
      }
      spec {
        priority_class_name = local.priority
        container {
          name  = "restaurant"
          image = "tobiaszimmer/exam-restaurant-service:main-1.0.0-release"
          env {
            name = "RESTAURANT_SERVICE_DB"
            value = format("jdbc:postgresql://postgres-restaurant-postgresql:5432/%s", var.restaurant_postgres_db)
          }
          env {
            name  = "RESTAURANT_DB_USER"
            value = var.restaurant_postgres_user
          }
          env {
            name  = "RESTAURANT_DB_PASSWORD"
            value = var.restaurant_postgres_user_password
          }
          env {
            name = "CASE_MANAGEMENT_CAMUNDA_BASE_URL"
            value = "http://camunda:8080/engine-rest"
          }
          env {
            name = "KAFKA_BOOTSTRAP_SERVER"
            value = "kafka:9092"
          }
          env {
            name = "AUTH_GRPC_HOST"
            value = "auth"
          }
          env {
            name = "AUTH_GRPC_PORT"
            value = "8080"
          }
          env {
            name = "GRPC_SERVER_PORT"
            value = "9791"
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

resource "kubernetes_persistent_volume_claim" "restaurant_volume" {
  metadata {
    name      = "postgresql-restaurant-claim"
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

resource "kubernetes_service" "restaurant" {
  metadata {
    namespace = local.namespace
    name      = "restaurant"
  }
  spec {
    selector = {
      app = "restaurant"
    }
    port {
      name = "rest"
      port        = 8080
      target_port = "8080"
    }
    port {
      name = "grpc"
      port        = 9791
      target_port = "9791"
    }
  }
}

resource "helm_release" "restaurant_postgres" {
  chart      = "postgresql"
  repository = "https://charts.bitnami.com/bitnami"
  name       = "postgres-restaurant"
  namespace  = local.namespace

  set {
    name  = "primary.persistence.enabled"
    value = "true"
  }
  set {
    name  = "primary.persistence.existingClaim"
    value = kubernetes_persistent_volume_claim.restaurant_volume.metadata.0.name
  }
  set {
    name  = "auth.enablePostgresUser"
    value = "false"
  }
  set {
    name  = "auth.username"
    value = var.restaurant_postgres_user
  }
  set {
    name  = "auth.password"
    value = var.restaurant_postgres_user_password
  }
  set {
    name  = "auth.database"
    value = var.restaurant_postgres_db
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
