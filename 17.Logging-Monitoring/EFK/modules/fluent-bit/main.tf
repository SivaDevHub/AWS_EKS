################################################################################

resource "helm_release" "fluent-bit" {
  count      = var.enabled ? 1 : 0
  name       = "fluent-bit"
  repository = "https://fluent.github.io/helm-charts"
  chart      = "fluent-bit"
  namespace  = "kube-system"
  version    = var.chart_version
    values     = [
    file("${path.module}/values.yaml")  # Reference the Helm values file
  ]
}
