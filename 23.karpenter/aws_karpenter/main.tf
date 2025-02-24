################################################################################
# karpenter CRDs installation
################################################################################

# List of CRD URLs
locals {
  crds_urls = [
    "https://raw.githubusercontent.com/aws/karpenter/v1.0.0/pkg/apis/crds/karpenter.k8s.aws_ec2nodeclasses.yaml",
    "https://raw.githubusercontent.com/aws/karpenter/v1.0.0/pkg/apis/crds/karpenter.sh_nodeclaims.yaml",
    "https://raw.githubusercontent.com/aws/karpenter/v1.0.0/pkg/apis/crds/karpenter.sh_nodepools.yaml",
  ]
}

data "http" "karpenter_crd" {
  for_each = var.enabled ? toset(local.crds_urls) : []
  url = each.value
}

# Install the CRDs from the URLs
resource "kubernetes_manifest" "crds" {
  for_each = var.enabled ? data.http.karpenter_crd : {}
  manifest = yamldecode(each.value.response_body)
}

################################################################################
# Karpenter Helm release
################################################################################

module "karpenter" {
  source = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "20.24.3"
  cluster_name = var.cluster_name
  enable_v1_permissions = var.enable_v1_permissions
  create = var.enabled
  enable_pod_identity = var.enable_pod_identity
  create_pod_identity_association = var.create_pod_identity_association
  node_iam_role_additional_policies = var.node_iam_role_additional_policies
  tags = var.tags
}

# Deploy Karpenter via Helm
resource "helm_release" "karpenter" {
  count      = var.enabled ? 1 : 0
  namespace           = "kube-system"
  name                = "karpenter"
  repository          = "oci://public.ecr.aws/karpenter"
  chart               = "karpenter"
  version             = "1.0.0"
  wait                = false

  values = [
    <<-EOT
    serviceAccount:
      name: ${module.karpenter.service_account}
    settings:
      clusterName: ${var.cluster_name}
      clusterEndpoint: ${var.cluster_endpoint}
      interruptionQueue: ${module.karpenter.queue_name}
    EOT
  ]

  depends_on = [
    kubernetes_manifest.crds
  ]
}

################################################################################
# Karpenter NodeClass and NodePool Resources
################################################################################

# EC2NodeClass manifest
resource "kubernetes_manifest" "karpenter_node_class" {
  count      = var.enabled ? 1 : 0
  manifest = yamldecode(<<-EOT
    apiVersion: karpenter.k8s.aws/v1beta1
    kind: EC2NodeClass
    metadata:
      name: default
    spec:
      amiFamily: AL2023
      role: ${module.karpenter.node_iam_role_name}
      subnetSelectorTerms:
        - tags:
            karpenter.sh/discovery: ${var.cluster_name}
      securityGroupSelectorTerms:
        - tags:
            karpenter.sh/discovery: ${var.cluster_name}
      tags:
        karpenter.sh/discovery: ${var.cluster_name}
  EOT
  )

  depends_on = [
    kubernetes_manifest.crds,
    helm_release.karpenter
  ]
}

# NodePool manifest
resource "kubernetes_manifest" "karpenter_node_pool" {
  count      = var.enabled ? 1 : 0
  manifest = yamldecode(<<-EOT
    apiVersion: karpenter.sh/v1beta1
    kind: NodePool
    metadata:
      name: default
    spec:
      template:
        spec:
          nodeClassRef:
            name: default
          requirements:
            - key: "karpenter.k8s.aws/instance-category"
              operator: In
              values: ["t", "c", "m", "r"]
            - key: "karpenter.k8s.aws/instance-cpu"
              operator: In
              values: ["2", "4"] # , "8", "16", "32"]
            # - key: "karpenter.k8s.aws/instance-hypervisor"
            #   operator: In
            #   values: ["nitro"]
            # - key: "karpenter.k8s.aws/instance-generation"
            #   operator: Gt
            #   values: ["2"]
      limits:
        cpu: 1000
      disruption:
        consolidationPolicy: WhenEmpty
        consolidateAfter: 30s
  EOT
  )

  depends_on = [
    kubernetes_manifest.crds,
    kubernetes_manifest.karpenter_node_class
  ]
}

################################################################################
# Example Deployment using the pause image
################################################################################

resource "kubernetes_manifest" "karpenter_example_deployment" {
  count      = var.enabled ? 1 : 0
  manifest = yamldecode(<<-EOT
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: inflate
      namespace: kube-system
    spec:
      replicas: 0
      selector:
        matchLabels:
          app: inflate
      template:
        metadata:
          labels:
            app: inflate
        spec:
          terminationGracePeriodSeconds: 0
          containers:
            - name: inflate
              image: public.ecr.aws/eks-distro/kubernetes/pause:3.7
              resources:
                requests:
                  cpu: 1
  EOT
  )

  depends_on = [
    kubernetes_manifest.crds,
    helm_release.karpenter
  ]
}
