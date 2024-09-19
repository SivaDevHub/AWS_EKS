name                  = "eks-vpc"
region                = "us-east-1"
azs                   = ["us-east-1a", "us-east-1b"]
vpc_cidr              = "10.0.0.0/17"
public_subnets        = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets       = ["10.0.3.0/24", "10.0.4.0/24"]
public_subnet_suffix  = "eks-public"
private_subnet_suffix = "eks-private"
private_subnet_tags   = { "kubernetes.io/role/internal-elb" = "1" }
public_subnet_tags    = { "kubernetes.io/role/elb" = "1" }
tags = {
  Owner       = "EKS"
  Environment = "QA"
}

