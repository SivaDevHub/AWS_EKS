variable "chart_version" {
  type    = string
}

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
