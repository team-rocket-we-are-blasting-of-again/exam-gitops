resource "kubernetes_deployment" "gateway" {
  metadata {
    namespace = local.namespace
    name      = "gateway"
    labels = {
      app = "gateway"
    }
  }
  spec {
    selector {
      match_labels = {
        app = "gateway"
      }
    }
    template {
      metadata {
        labels = {
          app = "gateway"
        }
      }
      spec {
        priority_class_name = local.priority
        container {
          name  = "gateway"
          image = "tobiaszimmer/exam-api-gateway:feature-monitoring-0.0.3-snapshot"
          env {
            name  = "GATEWAY_SERVER_PORT"
            value = "8080"
          }
          env {
            name  = "GATEWAY_USERNAME"
            value = var.gateway_username
          }
          env {
            name  = "GATEWAY_PASSWORD"
            value = var.gateway_password
          }
          env {
            name  = "GATEWAY_DB_URL"
            value = format("r2dbc:postgresql://postgres-gateway-postgresql:5432/%s", var.gateway_postgres_db)
          }
          env {
            name  = "GATEWAY_DB_USERNAME"
            value = var.gateway_postgres_user
          }
          env {
            name  = "GATEWAY_DB_POSTGRES"
            value = var.gateway_postgres_user_password
          }
          env {
            name  = "GATEWAY_FLYWAY_URL"
            value = format("jdbc:postgresql://postgres-gateway-postgresql:5432/%s", var.gateway_postgres_db)
          }
          env {
            name  = "GATEWAY_FLYWAY_USERNAME"
            value = var.gateway_postgres_user
          }
          env {
            name  = "GATEWAY_FLYWAY_PASSWORD"
            value = var.gateway_postgres_user_password
          }
          env {
            name  = "GATEWAY_KAFKA_BOOTSTRAP_SERVERS"
            value = format("%s:9092", kubernetes_service.kafka.metadata.0.name)
          }
          env {
            name  = "GATEWAY_AUTH_GRPC_URL"
            value = "static://auth:9000"
          }
        }
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "gateway_volume" {
  metadata {
    name      = "postgresql-gateway-claim"
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

resource "kubernetes_service" "gateway" {
  metadata {
    namespace = local.namespace
    name      = "gateway"
  }
  spec {
    selector = {
      app = "gateway"
    }
    port {
      port        = 8080
      target_port = "8080"
    }
  }
}

resource "helm_release" "gateway_postgres" {
  chart      = "postgresql"
  repository = "https://charts.bitnami.com/bitnami"
  name       = "postgres-gateway"
  namespace  = local.namespace

  set {
    name  = "primary.persistence.enabled"
    value = "true"
  }
  set {
    name  = "primary.persistence.existingClaim"
    value = kubernetes_persistent_volume_claim.gateway_volume.metadata.0.name
  }
  set {
    name  = "auth.enablePostgresUser"
    value = "false"
  }
  set {
    name  = "auth.username"
    value = var.gateway_postgres_user
  }
  set {
    name  = "auth.password"
    value = var.gateway_postgres_user_password
  }
  set {
    name  = "auth.database"
    value = var.gateway_postgres_db
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
