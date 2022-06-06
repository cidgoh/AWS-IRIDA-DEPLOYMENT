locals {
  instance = var.instance == "" ? "default" : var.instance
}

variable "claim_name" {
  type        = string
  description = "Name of user data PVC"
}

variable "lb_annotations" {
  type = map(string)
  default = {}
  description = "Annotations to pass to the ingress load-balancer (https://gist.github.com/mgoodness/1a2926f3b02d8e8149c224d25cc57dc1)"
}

variable "namespace" {
  default = null
  description = "Instance of kubernetes_namespace to provision instance resources under"
}