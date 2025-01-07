

################################################################################
# Aws Elasticsearch DNS Service Account
################################################################################
data "aws_caller_identity" "current" {}

resource "aws_iam_role" "elasticsearch" {
  count      = var.enabled ? 1 : 0
  name = "elasticsearch-ebs-csi-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(var.oidc_issuer, "https://", "")}"
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${replace(var.oidc_issuer, "https://", "")}:aud": "sts.amazonaws.com",
            "${replace(var.oidc_issuer, "https://", "")}:sub" = "system:serviceaccount:kube-system:elasticsearch"
          }
        }
      }
    ]
  })
}


resource "aws_iam_policy" "elasticsearch_iam_policy" {
  count      = var.enabled ? 1 : 0
  name        = "elasticsearch_iam_policy"
  description = "Policy to allow elasticsearch to create EBS volumes"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "ec2:*"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "elasticsearch_attachment" {
  count      = var.enabled ? 1 : 0
  role       = aws_iam_role.elasticsearch[0].name
  policy_arn = aws_iam_policy.elasticsearch_iam_policy[0].arn
}


################################################################################
# Aws elasticsearch DNS Service Account
################################################################################

resource "kubernetes_service_account" "service-account" {
  count      = var.enabled ? 1 : 0
  metadata {
    name      = "elasticsearch"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.elasticsearch[0].arn
    }
  }
}

################################################################################

resource "helm_release" "elasticsearch" {
  count      = var.enabled ? 1 : 0
  name       = "elasticsearch"
  repository = "https://helm.elastic.co"
  chart      = "elasticsearch"
  namespace  = "kube-system"
  version    = var.chart_version
  set {
    name = "persistence.labels.enabled"
    value = "true"
  }
  set {
    name = "replicas"
    value = "1"
  }
  set {
    name = "volumeClaimTemplate.storageClassName"
    value = "gp2"
  }
  # set {
  #   name  = "clusterName"
  #   value = "elasticsearch"
  # }
  # set {
  #   name  = "rbac.serviceAccountName"
  #   value = "elasticsearch"
  # }
  # set {
  #   name  = "rbac.create"
  #   value = "false"
  # }
  # set {
  #   name  = "rbac.serviceAccountAnnotations.eks\\.amazonaws\\.com/role-arn"
  #   value = aws_iam_role.elasticsearch[0].arn
  # }
}
