#resource "kubernetes_deployment" "courier" {
#  depends_on = [time_sleep.wait_for_gateway, kubernetes_deployment.camunda, kubernetes_deployment.kafka]
#  metadata {
#    namespace = local.namespace
#    name      = "courier"
#    labels = {
#      app = "courier"
#    }
#  }
#  spec {
#    selector {
#      match_labels = {
#        app = "courier"
#      }
#    }
#    template {
#      metadata {
#        labels = {
#          app = "courier"
#        }
#      }
#      spec {
#        priority_class_name = local.priority
#        container {
#          name  = "courier"
#          image = "tobiaszimmer/exam-courier-service:main-1.1.0-RELEASE"
#          env {
#            name  = "COURIER_SERVICE_PORT"
#            value = "8080"
#          }
#          env {
#            name  = "COURIER_SERVICE_DDL_MODE"
#            value = "create"
#          }
#          env {
#            name  = "COURIER_SERVICE_DB"
#            value = format("jdbc:postgresql://postgres-courier-postgresql:5432/%s", var.courier_postgres_db)
#          }
#          env {
#            name  = "COURIER_DB_USER"
#            value = var.courier_postgres_user
#          }
#          env {
#            name  = "COURIER_DB_PASSWORD"
#            value = var.courier_postgres_user_password
#          }
#          env {
#            name  = "CASE_MANAGEMENT_CAMUNDA_BASE_URL"
#            value = "http://camunda:8080/engine-rest"
#          }
#          env {
#            name  = "KAFKA_BOOTSTRAP_SERVER"
#            value = "kafka:9092"
#          }
#          env {
#            name  = "AUTH_GRPC_HOST"
#            value = "auth"
#          }
#          env {
#            name  = "AUTH_GRPC_PORT"
#            value = "8080"
#          }
#          env {
#            name  = "CUSTOMER_GRPC_HOST"
#            value = "customer"
#          }
#          env {
#            name  = "CUSTOMER_GRPC_PORT"
#            value = "9012"
#          }
#          env {
#            name  = "GATEWAY_USERNAME"
#            value = var.gateway_username
#          }
#          env {
#            name  = "GATEWAY_PASSWORD"
#            value = var.gateway_password
#          }
#        }
#      }
#    }
#  }
#}
#
#resource "kubernetes_persistent_volume_claim" "courier_volume" {
#  metadata {
#    name      = "postgresql-courier-claim"
#    namespace = local.namespace
#  }
#  spec {
#    access_modes = ["ReadWriteOnce"]
#    resources {
#      requests = {
#        storage = "1Gi"
#      }
#    }
#  }
#}
#
#resource "kubernetes_service" "courier" {
#  metadata {
#    namespace = local.namespace
#    name      = "courier"
#  }
#  spec {
#    selector = {
#      app = "courier"
#    }
#    port {
#      port        = 8080
#      target_port = "8080"
#    }
#  }
#}
#
#resource "helm_release" "courier_postgres" {
#  chart      = "postgresql"
#  repository = "https://charts.bitnami.com/bitnami"
#  name       = "postgres-courier"
#  namespace  = local.namespace
#
#  set {
#    name  = "primary.persistence.enabled"
#    value = "true"
#  }
#  set {
#    name  = "primary.persistence.existingClaim"
#    value = kubernetes_persistent_volume_claim.courier_volume.metadata.0.name
#  }
#  set {
#    name  = "auth.enablePostgresUser"
#    value = "false"
#  }
#  set {
#    name  = "auth.username"
#    value = var.courier_postgres_user
#  }
#  set {
#    name  = "auth.password"
#    value = var.courier_postgres_user_password
#  }
#  set {
#    name  = "auth.database"
#    value = var.courier_postgres_db
#  }
#  set {
#    name  = "architecture"
#    value = "standard"
#  }
#  set {
#    name  = "primary.priorityClassName"
#    value = local.priority
#  }
#  set {
#    name  = "primary.persistence.size"
#    value = "1Gi"
#  }
#}
