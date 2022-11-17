resource "helm_release" "camunda_postgres" {
  chart     = "bitnami/postgresql"
  name      = "postgres-camunda"
  namespace = local.namespace

  set {
    name  = "primary.persistence.enabled"
    value = "true"
  }
  set {
    name  = "primary.persistence.existingClaim"
    value = kubernetes_persistent_volume_claim.camunda_volume.metadata.0.name
  }
  set {
    name  = "auth.enablePostgresUser"
    value = "true"
  }
  set {
    name  = "auth.postgresPassword"
    value = var.camunda_postgres_root_password
  }
  set {
    name  = "auth.username"
    value = var.camunda_postgres_user
  }
  set {
    name  = "auth.password"
    value = var.camunda_postgres_user_password
  }
  set {
    name  = "auth.database"
    value = var.camunda_postgres_db
  }
}