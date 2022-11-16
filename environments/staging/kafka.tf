resource "kubernetes_deployment" "kafka" {
  metadata {
    namespace = local.namespace
    name   = "kafka"
    labels = {
      app = "kafka"
    }
  }
  spec {
    selector {
      match_labels = {
        app = "kafka"
      }
    }
    template {
      metadata {
        labels = {
          app = "kafka"
        }
      }
      spec {
        container {
          name  = "kafka"
          image = "bitnami/kafka:3.3.1"
          port {
            container_port = 9092
          }
          env {
            name  = "KAFKA_BROKER_ID"
            value = "1"
          }
          env {
            name  = "KAFKA_ZOOKEEPER_CONNECT"
            value = "zookeeper:2181"
          }
          env {
            name  = "KAFKA_LISTENER_SECURITY_PROTOCOL_MAP"
            value = "PLAINTEXT:PLAINTEXT"
          }
          env {
            name  = "KAFKA_LISTENERS"
            value = "PLAINTEXT://:9092"
          }
          env {
            name  = "KAFKA_ADVERTISED_LISTENERS"
            value = "PLAINTEXT://kafka:9092"
          }
          env {
            name  = "KAFKA_AUTO_CREATE_TOPICS_ENABLE"
            value = "true"
          }
          env {
            name  = "KAFKA_NUM_PARTITIONS"
            value = "3"
          }
          env {
            name  = "ALLOW_PLAINTEXT_LISTENER"
            value = "yes"
          }
        }
        priority_class_name = "staging"
      }
    }
  }
}
resource "kubernetes_service" "kafka" {
  metadata {
    namespace = local.namespace
    name = "kafka"
  }
  spec {
    selector = {
      app = "kafka"
    }
    port {
      port = 9092
      target_port = "9092"
    }
  }
}

resource "kubernetes_deployment" "zookeeper" {
  metadata {
    namespace = local.namespace
    name   = "zookeeper"
    labels = {
      app = "zookeeper"
    }
  }
  spec {
    selector {
      match_labels = {
        app = "zookeeper"
      }
    }
    template {
      metadata {
        labels = {
          app = "zookeeper"
        }
      }
      spec {
        container {
          name  = "zookeeper"
          image = "bitnami/zookeeper:3.8"
          port {
            container_port = 2181
          }
          env {
            name  = "ALLOW_ANONYMOUS_LOGIN"
            value = "yes"
          }
        }
        priority_class_name = "staging"
      }
    }
  }
}

resource "kubernetes_service" "zookeeper" {
  metadata {
    name = "zookeeper"
    namespace = local.namespace
  }
  spec {
    selector = {
      app = "zookeeper"
    }
    port {
      port = 2181
      target_port = "2181"
    }
  }
}

