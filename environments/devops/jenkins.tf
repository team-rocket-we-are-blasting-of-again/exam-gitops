resource "kubernetes_cluster_role" "jenkins" {
  metadata {
    name = "jenkins-admin"
  }
  rule {
    api_groups = [""]
    verbs = ["*"]
    resources = ["*"]
  }
}

resource "kubernetes_manifest" "jenkins_service_account" {
  manifest = {
    "apiVersion" = "v1"
    "kind"       = "ServiceAccount"
    "metadata" = {
      "namespace" = local.namespace
      "name"      = "jenkins-admin"
    }
    "automountServiceAccountToken" = true
  }
}

resource "kubernetes_cluster_role_binding" "jenkins" {
  metadata {
    name = "jenkins-admin"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "jenkins-admin"
  }
  subject {
    kind = "ServiceAccount"
    name = "jenkins-admin"
    namespace = local.namespace
  }
}

resource "kubernetes_persistent_volume_claim" "jenkins_volume" {
  metadata {
    name = "jenkins-pv-claim"
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

resource "kubernetes_deployment" "jenkins" {
  metadata {
    name = "jenkins"
    namespace = local.namespace
  }
  spec {
    selector {
      match_labels = {
        app = "jenkins-server"
      }
    }
    template {
      metadata {
        labels = {
          app = "jenkins-server"
        }
      }
      spec {
        security_context {
          fs_group = "1000"
          run_as_user = "1000"
        }
        service_account_name = "jenkins-admin"
        container {
          name = "jenkins"
          image = "jenkins/jenkins:latest"
#          resources {
#            limits = {
#              memory = "1Gi"
#              cpu = "500m"
#            }
#            requests = {
#              memory = "500Mi"
#              cpu = "500m"
#            }
#          }
          port {
            name = "httpport"
            container_port = 8080
          }
          port {
            name = "jnlpport"
            container_port = 50000
          }
          liveness_probe {
            http_get {
              path = "/login"
              port = 8080
            }
            initial_delay_seconds = 90
            period_seconds = 10
            timeout_seconds = 5
            failure_threshold = 5
          }
          readiness_probe {
            http_get {
              path = "/login"
              port = 8080
            }
            initial_delay_seconds = 60
            period_seconds = 10
            timeout_seconds = 5
            failure_threshold = 3
          }
          volume_mount {
            name       = "jenkins-data"
            mount_path = "/var/jenkins_home"
          }
        }
        volume {
          name = "jenkins-data"
          persistent_volume_claim {
            claim_name = "jenkins-pv-claim"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "jenkins" {
  metadata {
    name = "jenkins-service"
    namespace = local.namespace
    annotations = {
      "prometheus.io/scrape" = "true"
      "prometheus.io/path" =   "/"
      "prometheus.io/port" =   "8080"
    }
  }
  spec {
    selector = {
      app = "jenkins-server"
    }
    port {
      port = 8080
      target_port = "8080"
    }
  }
}