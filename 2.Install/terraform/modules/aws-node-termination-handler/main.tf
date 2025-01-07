resource "helm_release" "metrics-server" {
  count      = var.enabled ? 1 : 0
  name       = "aws-node-termination-handler"
  repository = "https://aws.github.io/eks-charts/"
  chart      = "aws-node-termination-handler"
  namespace  = "kube-system"
  version    = var.chart_version
  create_namespace = true
}
