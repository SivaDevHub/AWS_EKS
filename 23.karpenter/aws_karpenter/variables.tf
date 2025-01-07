variable "cluster_name" {
  type    = string
}


variable "cluster_endpoint" {
  type    = string
}

variable "enable_v1_permissions" {
  description = "Determines whether to enable permissions suitable for v1+ (`true`) or for v0.33.x-v0.37.x (`false`)"
  type        = bool
  default     = false
}

variable "enabled" {
  description = "Controls if resources should be created (affects nearly all resources)"
  type        = bool
  default     = true
}

variable "enable_pod_identity" {
  description = "Determines whether to enable support for EKS pod identity"
  type        = bool
  default     = true
}

variable "create_pod_identity_association" {
  description = "Determines whether to create pod identity association"
  type        = bool
  default     = false
}

variable "node_iam_role_additional_policies" {
  description = "Additional policies to be added to the IAM role"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

