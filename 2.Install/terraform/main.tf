# module "vpc" {
#   source          = "./modules/vpc"
#   cidr            = var.vpc_cidr
#   public_subnets  = var.public_subnets
#   private_subnets = var.private_subnets
#   public_subnet_suffix = var.private_subnet_suffix
#   private_subnet_suffix = var.private_subnet_suffix
#   private_subnet_tags = var.private_subnet_tags
#   public_subnet_tags = var.public_subnet_tags
#   tags = var.tags
#   azs = var.azs
# }

#https://github.com/aws-ia/terraform-aws-eks-blueprints-addons/blob/main/README.md

data "aws_availability_zones" "available" {}

##### VPC ########

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.13.0"

  name                 = var.name
  cidr                 = var.vpc_cidr
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = var.private_subnets
  public_subnets       = var.public_subnets
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = var.tags
  public_subnet_tags   = var.public_subnet_tags
  private_subnet_tags  = var.private_subnet_tags
}

module "ebs_csi_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name             = "eks-ebs-csi"
  attach_ebs_csi_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
}
##### EKS Cluster ########
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.name
  cluster_version = "1.29"

  cluster_endpoint_public_access = true

  cluster_addons = {
    coredns = {}
    eks-pod-identity-agent = {}
    # kube-proxy             = {}
    # vpc-cni                = {}
    # aws-efs-csi-driver     = {}
    aws-ebs-csi-driver     = {
      service_account_role_arn = module.ebs_csi_irsa_role.iam_role_arn
    }
  }

  vpc_id = module.vpc.vpc_id

  control_plane_subnet_ids = module.vpc.public_subnets

  subnet_ids = module.vpc.private_subnets
  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = ["t3.medium"]
  }

  cluster_encryption_config = {}

  eks_managed_node_groups = {
    eks-cluster-dev = {
      min_size     = 3
      max_size     = 8
      desired_size = 3
      instance_types = ["t3.medium"]
    }
  }

  enable_cluster_creator_admin_permissions = true
  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}

##### AWS ACM ########
module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name  = "891376932848.realhandsonlabs.net"
  zone_id      = "Z01834871R35H99O5X1FV"

  validation_method = "DNS"

  subject_alternative_names = [
    "devcentral.891376932848.realhandsonlabs.net",
  ]

  wait_for_validation = true

  tags = {
    Name = "891376932848.realhandsonlabs.net "
  }
}
##### Load Balancer Controller ########
module "aws_alb_controller" {
  enabled           = true
  source            = "../../7.Ingress/AWSLoadbalancer/aws-alb-controller"
  region            = var.region
  env_name          = var.env_name
  cluster_name      = var.name
  vpc_id            = module.vpc.vpc_id
  oidc_provider_arn = module.eks.oidc_provider_arn
  chart_version     = "1.8.3"
}


#####Aws External DNS #######

module "aws_external_dns" {
  enabled       = true
  source        = "../../10.External-DNS/aws-ext-dns"
  cluster_name  = var.name
  chart_version = "1.15.0"
  oidc_issuer   = module.eks.cluster_oidc_issuer_url
}


#### AWS Cluster Auto Scaler ####
module "aws_cluster_auto_scaler" {
  enabled      = false
  source       = "../../22.cluster-autoscaler/aws-cluster-autoscaler"
  cluster_name = var.name
  oidc_issuer  = module.eks.cluster_oidc_issuer_url
  region       = var.region
}


# ##### AWS Karpenter Cluster Auto Scaler ####
module "eks_karpenter" {
  enabled                         = false
  source                          = "../../23.karpenter/aws_karpenter"
  cluster_name                    = var.name
  cluster_endpoint                = module.eks.cluster_endpoint
  enable_v1_permissions           = false
  enable_pod_identity             = false
  create_pod_identity_association = false
  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
  tags = var.tags
}

#### k8s Dashboard ####

module "k8s_dashboard" {
  source = "./modules/k8s-dashboard"
  enabled = false
  chart_version = "7.6.1"
}

#### Metrics Server ####

module "k8s-metrics-server" {
  source = "./modules/k8s-metrics-server"
  enabled = false
  chart_version = "3.12.1"
}

#### aws-node-termination-handler ####
module "aws-node-termination-handler" {
  source = "./modules/aws-node-termination-handler"
  enabled = false
  chart_version = "0.21.0"
}

#### Newrelic ####
module "newrelic" {
  source= "./modules/newrelic"
  enabled = false
  cluster_name  = var.name
  chart_version = "5.0.45"
  licenseKey = "55eac257c8451e717fc4bbf247a21cd5FFFFNRAL"
}
#### ElasticSearch ####
module "elasticsearch" {
  source= "../../17.Logging-Monitoring/EFK/modules/elasticsearch"
  enabled = false
  cluster_name  = var.name
  chart_version = "8.5.1"
  oidc_issuer   = module.eks.cluster_oidc_issuer_url
}
#### Kibana ####
module "kibana" {
  source= "../../17.Logging-Monitoring/EFK/modules/kibana"
  enabled = false
  cluster_name  = var.name
  chart_version = "8.5.1"
  depends_on = [module.elasticsearch]
}
#### fluent-bit ####
module "fluent-bit" {
  source= "../../17.Logging-Monitoring/EFK/modules/fluent-bit"
  enabled = false
  chart_version = "0.47.9"
}


#### Prometheous ####
#### Grafana ####
#### Loki ####