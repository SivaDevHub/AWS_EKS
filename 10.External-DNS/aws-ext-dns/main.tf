

################################################################################
# Aws External DNS Service Account
################################################################################
data "aws_caller_identity" "current" {}


resource "aws_iam_role" "external_dns" {
  count      = var.enabled ? 1 : 0
  name = "external-dns-role"
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
            "${replace(var.oidc_issuer, "https://", "")}:sub" = "system:serviceaccount:kube-system:external-dns"
          }
        }
      }
    ]
  })
}


resource "aws_iam_policy" "external_dns_policy" {
  count      = var.enabled ? 1 : 0
  name        = "ExternalDNSPolicy"
  description = "Policy to allow ExternalDNS to manage Route53 records"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "route53:ChangeResourceRecordSets",
          "route53:ListHostedZones",
          "route53:ListResourceRecordSets"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "external_dns_attachment" {
  count      = var.enabled ? 1 : 0
  role       = aws_iam_role.external_dns[0].name
  policy_arn = aws_iam_policy.external_dns_policy[0].arn
}


################################################################################
# Aws External DNS Service Account
################################################################################

resource "kubernetes_service_account" "service-account" {
  count      = var.enabled ? 1 : 0
  metadata {
    name      = "external-dns"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.external_dns[0].arn
    }
  }
}
################################################################################
# Install External DNS With Helm
################################################################################

resource "helm_release" "lb" {
  count      = var.enabled ? 1 : 0
  name       = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns"
  chart      = "external-dns"
  namespace  = "kube-system"
  version    = var.chart_version
  depends_on = [
    kubernetes_service_account.service-account
  ]
  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name = "provider.name"
    value = "aws"
  }

  set {
    name = "policy"
    value = "upsert-only"
  }

  set {
    name  = "serviceAccount.name"
    value = "external-dns"
  }

  set {
    name  = "sources"
    value = "{service,ingress}"
  }
}
