provider "aws" {
  region = var.region
}

module "vpc" {
  source          = "./modules/vpc"
  cidr            = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  public_subnet_suffix = var.private_subnet_suffix
  private_subnet_suffix = var.private_subnet_suffix
  private_subnet_tags = var.private_subnet_tags
  public_subnet_tags = var.public_subnet_tags
  tags = var.tags
  azs = var.azs
}