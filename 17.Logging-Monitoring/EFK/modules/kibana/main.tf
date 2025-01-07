################################################################################

resource "helm_release" "kibana" {
  count      = var.enabled ? 1 : 0
  name       = "kibana"
  repository = "https://helm.elastic.co"
  chart      = "kibana"
  namespace  = "kube-system"
  version    = var.chart_version
    values     = [
    file("${path.module}/values.yaml")  # Reference the Helm values file
  ]
  # set {
  #   name  = "elasticsearchHosts"
  #   value = "https://eks-vpc-master:9200"
  # }
  # set {
  #   name  = "elasticsearchCertificateSecret"
  #   value = "eks-vpc-master-certs"
  # }
  # set {
  #   name  = "elasticsearchCertificateAuthoritiesFile"
  #   value = "ca.crt"
  # }
  # set {
  #   name  = "elasticsearchCredentialSecret"
  #   value = "eks-vpc-master-credentials"
  # }
  set {
    name  = "service.type"
    value = "LoadBalancer"
  }
}
