# Create IAM role + automatically make it available to cluster autoscaler service account
data "aws_caller_identity" "current" {}

module "iam_assumable_role_admin" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  create_role                   = true
  role_name                     = "cluster-autoscaler"
  provider_url                  = replace(var.oidc_issuer, "https://", "")
  role_policy_arns              = [aws_iam_policy.cluster_autoscaler.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:cluster-autoscaler-aws-cluster-autoscaler"]

  # tags = {
  #   Owner = split("/", data.aws_caller_identity.current.arn)[1]
  #   AutoTag_Creator = data.aws_caller_identity.current.arn
  # }
}

resource "aws_iam_policy" "cluster_autoscaler" {
  name_prefix = "cluster-autoscaler"
  description = "EKS cluster-autoscaler policy for cluster ${var.cluster_name}"
  policy      = data.aws_iam_policy_document.cluster_autoscaler.json
}

data "aws_iam_policy_document" "cluster_autoscaler" {
  statement {
    sid       = "clusterAutoscalerAll"
    effect    = "Allow"

    actions   = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "ec2:DescribeLaunchTemplateVersions",
      "ec2:DescribeInstanceTypes",
      "ec2:*",
      "autoscaling:*"

    ]

    resources = ["*"]
  }

  statement {
    sid        = "clusterAutoscalerOwn"
    effect     = "Allow"

    actions    = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "autoscaling:UpdateAutoScalingGroup",
    ]

    resources  = ["*"]

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/kubernetes.io/cluster/${var.cluster_name}"
      values   = ["owned"]
    }

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/enabled"
      values   = ["true"]
    }
  }
}
resource "helm_release" "cluster-autoscaler" {
  count      = var.enabled ? 1 : 0
  name        = "cluster-autoscaler"
  namespace   = "kube-system"
  repository  = "https://kubernetes.github.io/autoscaler"
  chart       = "cluster-autoscaler"

  set{
    name  = "cloudProvder"
    value = "aws"
  }

  set{
    name  = "awsRegion"
    value = var.region
  }

  set{
    name  = "autoDiscovery.clusterName"
    value = var.cluster_name
  }

  set {
    name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.iam_assumable_role_admin.iam_role_arn
  }

}