resource "helm_release" "metrics-server" {
  count      = var.enabled ? 1 : 0
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = "kube-system"
  version    = var.chart_version
  create_namespace = true
}
