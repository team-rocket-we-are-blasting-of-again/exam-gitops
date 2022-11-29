resource "helm_release" "kube-prometheus-stack" {
  repository = "https://prometheus-community.github.io/helm-charts"
  chart = "kube-prometheus-stack"
  name  = "kube-prometheus-stack"
  namespace = local.namespace
  values = [
    file("${path.module}/config/kube-prometheus-stack-values.yaml")
  ]
}

resource "helm_release" "promtail" {
  repository = "https://grafana.github.io/helm-charts"
  chart = "promtail"
  name  = "promtail"
  namespace = local.namespace
  values = [
    file("${path.module}/config/promtail-values.yaml")
  ]
}

resource "helm_release" "loki" {
  repository = "https://grafana.github.io/helm-charts"
  chart = "loki-distributed"
  name  = "loki"
  namespace = local.namespace
  set {
    name  = "gateway.service.port"
    value = "3101"
  }
}

