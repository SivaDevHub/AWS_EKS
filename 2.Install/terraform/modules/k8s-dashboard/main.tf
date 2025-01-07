resource "helm_release" "kubernetes-dashboard" {
  count      = var.enabled ? 1 : 0
  name       = "kubernetes-dashboard"
  repository = "https://kubernetes.github.io/dashboard/"
  chart      = "kubernetes-dashboard"
  namespace  = "kubernetes-dashboard"
  version    = var.chart_version
  create_namespace = true
}
