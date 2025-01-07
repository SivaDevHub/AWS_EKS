variable "enabled" {
  type    = bool
  default = true
}

variable "cluster_name" {
  type    = string
}

variable "oidc_issuer" {
  type    = string
}

variable "region" {
  type = string
}