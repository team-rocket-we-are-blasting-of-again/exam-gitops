resource "kubectl_manifest" "cluster_issuer" {
  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: ${local.cluster_issuer_name}
spec:
  acme:
    email: ${var.email}
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: letsencrypt-secret-prod
    solvers:
      - http01:
          ingress:
            class: nginx
YAML
}

# https://acme-v02.api.letsencrypt.org/directory

resource "kubectl_manifest" "certificate" {
  depends_on = [kubectl_manifest.cluster_issuer]
  yaml_body  = <<YAML
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: ${local.secret_name}
  namespace: ${local.namespace}
spec:
  secretName: ${local.secret_name}
  dnsNames:
    - ${format("monitor.%s", var.website)}
  issuerRef:
    name: ${local.cluster_issuer_name}
    kind: ClusterIssuer
YAML
}

resource "kubernetes_ingress_v1" "ingress" {
  depends_on             = [kubectl_manifest.certificate]
  wait_for_load_balancer = true
  metadata {
    namespace = local.namespace
    name      = "ingress"
    annotations = {
      "kubernetes.io/ingress.class"                    = "nginx"
      "cert-manager.io/cluster-issuer"                 = local.cluster_issuer_name
      "nginx.ingress.kubernetes.io/ssl-redirect"       = "false"
      "nginx.ingress.kubernetes.io/force-ssl-redirect" = "false"
      "nginx.ingress.kubernetes.io/limit-connections"  = "10"   # Connections per ip (could maybe be increased)
      "nginx.ingress.kubernetes.io/limit-rpm"          = "1000" # Requests per minute
    }
  }
  spec {
    tls {
      hosts = [
        format("monitor.%s", var.website),
      ]
      secret_name = local.secret_name
    }
    rule {
      host = format("monitor.%s", var.website)
      http {
        path {
          backend {
            service {
              name = "grafana"
              port {
                number = 3000
              }
            }
          }
          path_type = "Prefix"
          path      = "/"
        }
      }
    }
  }
}
