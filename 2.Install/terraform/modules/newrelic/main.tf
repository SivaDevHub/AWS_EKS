resource "helm_release" "newrelic" {
  count      = var.enabled ? 1 : 0
  name       = "newrelic-bundle"
  repository = "https://helm-charts.newrelic.com/"
  chart      = "nri-bundle" 
  namespace  = "kube-system"
  version    = var.chart_version

  set {
    name  = "global.licenseKey"
    value = var.licenseKey
  }

  set {
    name  = "global.cluster"
    value = var.cluster_name
  }

  set {
    name  = "newrelic-infrastructure.privileged"
    value = "true"
  }

  set {
    name  = "global.lowDataMode"
    value = "true"
  }

  set {
    name  = "kube-state-metrics.enabled"
    value = "true"
  }

  set {
    name  = "kubeEvents.enabled"
    value = "true"
  }

  set {
    name  = "newrelic-prometheus-agent.enabled"
    value = "true"
  }

  set {
    name  = "newrelic-prometheus-agent.lowDataMode"
    value = "true"
  }

  set {
    name  = "newrelic-prometheus-agent.config.kubernetes.integrations_filter.enabled"
    value = "false"
  }

  set {
    name  = "logging.enabled"
    value = "false"
  }

  set {
    name  = "newrelic-logging.lowDataMode"
    value = "true"
  }
}
