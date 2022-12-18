#resource "kubernetes_deployment" "customer" {
#  depends_on = [time_sleep.wait_for_gateway, kubernetes_deployment.camunda, kubernetes_deployment.kafka]
#  metadata {
#    namespace = local.namespace
#    name      = "customer"
#    labels = {
#      app = "customer"
#    }
#  }
#  spec {
#    selector {
#      match_labels = {
#        app = "customer"
#      }
#    }
#    template {
#      metadata {
#        labels = {
#          app = "customer"
#        }
#      }
#      spec {
#        priority_class_name = local.priority
#        container {
#          name  = "customer"
#          image = "tobiaszimmer/exam-customer-service:kafka_fail-1.0.4-RELEASE"
#          env {
#            name  = "SPRING_DATASOURCE_URL"
#            value = format("jdbc:postgresql://postgres-customer-postgresql:5432/%s", var.customer_postgres_db)
#          }
#          env {
#            name  = "SPRING_DATASOURCE_USERNAME"
#            value = var.customer_postgres_user
#          }
#          env {
#            name  = "SPRING_DATASOURCE_PASSWORD"
#            value = var.customer_postgres_user_password
#          }
#          env {
#            name  = "CAMUNDA_ENGINE_REST"
#            value = "http://camunda:8080/engine-rest/"
#          }
#          env {
#            name  = "KAFKA_BOOTSTRAP_SERVERS"
#            value = "kafka:9092"
#          }
#          env {
#            name  = "AUTH_GRPC_URL"
#            value = "static://auth:50051"
#          }
#          env {
#            name  = "RESTAURANT_GRPC_URL"
#            value = "static://restaurant:9791"
#          }
#          env {
#            name  = "GRPC_SERVER_PORT"
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
#resource "kubernetes_persistent_volume_claim" "customer_volume" {
#  metadata {
#    name      = "postgresql-customer-claim"
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
#resource "kubernetes_service" "customer" {
#  metadata {
#    namespace = local.namespace
#    name      = "customer"
#  }
#  spec {
#    selector = {
#      app = "customer"
#    }
#    port {
#      name        = "rest"
#      port        = 8012
#      target_port = "8012"
#    }
#    port {
#      name        = "grpc"
#      port        = 9012
#      target_port = "9012"
#    }
#  }
#}
#
#resource "helm_release" "customer_postgres" {
#  chart      = "postgresql"
#  repository = "https://charts.bitnami.com/bitnami"
#  name       = "postgres-customer"
#  namespace  = local.namespace
#
#  set {
#    name  = "primary.persistence.enabled"
#    value = "true"
#  }
#  set {
#    name  = "primary.persistence.existingClaim"
#    value = kubernetes_persistent_volume_claim.customer_volume.metadata.0.name
#  }
#  set {
#    name  = "auth.enablePostgresUser"
#    value = "false"
#  }
#  set {
#    name  = "auth.username"
#    value = var.customer_postgres_user
#  }
#  set {
#    name  = "auth.password"
#    value = var.customer_postgres_user_password
#  }
#  set {
#    name  = "auth.database"
#    value = var.customer_postgres_db
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
