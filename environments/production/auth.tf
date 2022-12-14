resource "kubernetes_deployment" "auth" {
  depends_on = [kubernetes_deployment.gateway]
  metadata {
    namespace = local.namespace
    name      = "auth"
    labels    = {
      app = "auth"
    }
  }
  spec {
    selector {
      match_labels = {
        app = "auth"
      }
    }
    template {
      metadata {
        labels = {
          app = "auth"
        }
      }
      spec {
        priority_class_name = local.priority
        container {
          name  = "auth"
          image = "tobiaszimmer/exam_auth_service:main-0.1.0"
          env {
            name  = "POSTGRES_HOST"
            value = "postgres-auth-postgresql"
          }
          env {
            name  = "POSTGRES_USER"
            value = var.auth_postgres_user
          }
          env {
            name  = "POSTGRES_DATABASE"
            value = var.auth_postgres_db
          }
          env {
            name  = "POSTGRES_PASSWORD"
            value = var.auth_postgres_user_password
          }
          env {
            name  = "POSTGRES_PORT"
            value = 5432
          }
          env {
            name  = "TOKEN_DURATION_HOURS"
            value = 12
          }
          env {
            name  = "ROCKET_PORT"
            value = 8080
          }
          env {
            name  = "GRPC_ADDRESS"
            value = "[::1]:50051"
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

resource "kubernetes_persistent_volume_claim" "auth_volume" {
  metadata {
    name      = "postgresql-auth-claim"
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

resource "kubernetes_service" "auth" {
  metadata {
    namespace = local.namespace
    name      = "auth"
  }
  spec {
    selector = {
      app = "auth"
    }
    port {
      name = "rest"
      port        = 8080
      target_port = "8080"
    }
    port {
      name = "grpc"
      port        = 50051
      target_port = "50051"
    }
  }
}

resource "helm_release" "auth_postgres" {
  chart      = "postgresql"
  repository = "https://charts.bitnami.com/bitnami"
  name       = "postgres-auth"
  namespace  = local.namespace

  set {
    name  = "primary.persistence.enabled"
    value = "true"
  }
  set {
    name  = "primary.persistence.existingClaim"
    value = kubernetes_persistent_volume_claim.auth_volume.metadata.0.name
  }
  set {
    name  = "auth.enablePostgresUser"
    value = "false"
  }
  set {
    name  = "auth.username"
    value = var.auth_postgres_user
  }
  set {
    name  = "auth.password"
    value = var.auth_postgres_user_password
  }
  set {
    name  = "auth.database"
    value = var.auth_postgres_db
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
