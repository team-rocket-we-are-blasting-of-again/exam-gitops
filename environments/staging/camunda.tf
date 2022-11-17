resource "kubernetes_deployment" "camunda" {
  metadata {
    namespace = local.namespace
    name      = "camunda"
    labels    = {
      app = "camunda"
    }
  }
  spec {
    selector {
      match_labels = {
        app = "camunda"
      }
    }
    template {
      metadata {
        labels = {
          app = "camunda"
        }
      }
      spec {
        container {
          name  = "camunda"
          image = "tobiaszimmer/exam-camunda-server:main-0.0.2"
          env {
            name  = "CAMUNDA_ADMIN_USERNAME"
            value = var.camunda_admin_user
          }
          env {
            name  = "CAMUNDA_ADMIN_PASSWORD"
            value = var.camunda_admin_password
          }
          env {
            name  = "CAMUNDA_ADMIN_EMAIL"
            value = var.email
          }
          env {
            name  = "CAMUNDA_ADMIN_FIRSTNAME"
            value = "Team"
          }
          env {
            name  = "CAMUNDA_ADMIN_LASTNAME"
            value = "Rocket"
          }
          env {
            name  = "DB_CONNECTION_STR"
            value = format("jdbc:postgresql://camunda:5432/%s", var.camunda_postgres_db)
          }
          env {
            name  = "DB_USERNAME"
            value = var.camunda_postgres_user
          }
          env {
            name  = "DB_PASSWORD"
            value = var.camunda_postgres_user_password
          }
        }
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "camunda_volume" {
  metadata {
    name      = "postgresql-data-claim"
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

resource "kubernetes_service" "camunda" {
  metadata {
    namespace = local.namespace
    name = "camunda"
  }
  spec {
    selector = {
      app = "camunda"
    }
    port {
      port = 8080
      target_port = "8080"
    }
  }
}
