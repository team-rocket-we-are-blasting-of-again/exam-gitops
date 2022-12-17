# TODO: depends on auth
resource "kubernetes_deployment" "legacy" {
  depends_on = [time_sleep.wait_for_gateway, kubernetes_deployment.kafka, kubernetes_deployment.legacy-postgres, kubernetes_deployment.legacy-redis, kubernetes_deployment.kafka_connect]
  metadata {
    namespace = local.namespace
    name      = "legacy"
    labels    = {
      app = "legacy"
    }
  }
  spec {
    selector {
      match_labels = {
        app = "legacy"
      }
    }
    template {
      metadata {
        labels = {
          app = "legacy"
        }
      }
      spec {
        priority_class_name = local.priority
        container {
          name  = "legacy"
          image = "tobiaszimmer/exam-legacy-system:main-1.0.0"
          env {
            name = "REDIS_HOST"
            value = "legacy_redis"
          }
          env {
            name = "REDIS_PORT"
            value = 6379
          }
          env {
            name = "DATA_SERVICE_URL"
            value = "http://legacy:9080/"
          }
          env {
            name = "DATA_SERVICE_JDBC_URL"
            value = format("jdbc:postgresql://legacy-postgres:5432/%s", var.gateway_postgres_db)
          }
          env {
            name  = "DATA_SERVICE_POSTGRES_USERNAME"
            value = var.gateway_postgres_user
          }
          env {
            name  = "DATA_SERVICE_POSTGRES_PASSWORD"
            value = var.gateway_postgres_user_password
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "legacy" {
  metadata {
    namespace = local.namespace
    name      = "legacy"
  }
  spec {
    selector = {
      app = "legacy"
    }
    port {
      name = "data_service"
      port        = 9080
      target_port = "9080"
    }
    port {
      name = "entry_service"
      port        = 9085
      target_port = "9085"
    }
  }
}

resource "kubernetes_deployment" "legacy-postgres" {
  metadata {
    name = "legacy-postgres"
    namespace = local.namespace
  }
  spec {
    selector {
      match_labels = {
        app = "legacy-postgres"
      }
    }
    template {
      metadata {
        labels = {
          app = "legacy-postgres"
        }
      }
      spec {
        priority_class_name = local.priority
        container {
          name = "legacy-postgres"
          image = "tobiaszimmer/exam-legacy-system:main-postgres"
          env {
            name = "POSTGRES_USER"
            value = var.gateway_postgres_user
          }
          env {
            name = "POSTGRES_PASSWORD"
            value = var.gateway_postgres_user_password
          }
          env {
            name = "POSTGRES_DB"
            value = var.gateway_postgres_db
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "legacy-postgres" {
  metadata {
    name = "legacy-postgres"
    namespace = local.namespace
  }
  spec {
    selector = {
      app = "legacy-postgres"
    }
    port {
      port = 5432
      target_port = "5432"
    }
  }
}

resource "kubernetes_deployment" "legacy-redis" {
  metadata {
    name = "legacy-redis"
    namespace = local.namespace
  }
  spec {
    selector {
      match_labels = {
        app = "legacy-redis"
      }
    }
    template {
      metadata {
        labels = {
          app = "legacy-redis"
        }
      }
      spec {
        priority_class_name = local.priority
        container {
          name = "legacy-redis"
          image = "redis:6.2-alpine"
        }
      }
    }
  }
}

resource "kubernetes_service" "legacy-redis" {
  metadata {
    name = "legacy-redis"
    namespace = local.namespace
  }
  spec {
    selector = {
      app = "legacy-redis"
    }
    port {
      port = 6379
      target_port = "6379"
    }
  }
}

resource "kubernetes_deployment" "legacy-translator" {
  depends_on = [kubernetes_deployment.kafka-connect, time_sleep.wait_for_gateway]
  metadata {
    name = "legacy-translator"
    namespace = local.namespace
  }
  spec {
    selector {
      match_labels = {
        app = "legacy-translator"
      }
    }
    template {
      metadata {
        labels = {
          app = "legacy-translator"
        }
      }
      spec {
        container {
          name = "legacy-translator"
          image = "tobiaszimmer/exam-legacy-translator:development-0.0.1-snapshot"
          env {
            name = "KAFKA_CONNECT_HOST"
            value = "kafka-connect"
          }
          env {
            name = "KAFKA_CONNECT_PORT"
            value = "8083"
          }
          env {
            name = "KAFKA_BOOTSTRAP_SERVERS"
            value = "kafka:9092"
          }
          env {
            name = "LEGACY_DB_URL"
            value = format("jdbc:postgresql://legacy-postgres:5432/%s", var.gateway_postgres_db)
          }
          env {
            name  = "LEGACY_DB_USERNAME"
            value = var.gateway_postgres_user
          }
          env {
            name  = "LEGACY_DB_PASSWORD"
            value = var.gateway_postgres_user_password
          }
          env {
            name = "RESTAURANT_DB_URL"
            value = format("jdbc:postgresql://postgres-restaurant-postgresql:5432/%s", var.restaurant_postgres_db)
          }
          env {
            name  = "RESTAURANT_DB_USERNAME"
            value = var.restaurant_postgres_user
          }
          env {
            name  = "RESTAURANT_DB_PASSWORD"
            value = var.restaurant_postgres_user_password
          }
          env {
            name = "POLL_INTERVAL_MS"
            value = "10000"
          }
        }
      }
    }
  }
}
