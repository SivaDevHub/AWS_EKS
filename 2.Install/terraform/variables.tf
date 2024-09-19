variable "name" {}
variable "region" {}
variable "azs" {}
variable "vpc_cidr" {}
variable "public_subnets" {}
variable "private_subnets" {}
variable "public_subnet_suffix" {}
variable "private_subnet_suffix" {}
variable "private_subnet_tags" {}
variable "public_subnet_tags" {}
variable "tags" {}
# variable "backend-s3-bucket-name" {
#   description = "Name to be used on all the resources as identifier"
#   type        = string
# }
# variable "backend-s3-path" {
#   description = "Name to be used on all the resources as identifier"
#   type        = string
# }
# variable "backend-dynamodb_table" {
#   description = "Name to be used on all the resources as identifier"
#   type        = string
# }