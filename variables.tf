variable "image" {

    type = string
    default = "quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.33.0"

}

variable "name" {

    type        = string
    description = "daemonset name"

}

variable "namespace" {

    type        = string
    description = "namespace to deploy daemonset to"

}

variable "whitelist_ip_ranges" {

    type    = list(string)
    default = [ "0.0.0.0/0" ]

}

variable "node_selector" {

    type = map
    default = null

}

variable "internal" {

    type = bool
    default = true

}

variable "vpc_cidr" {

    type = string
    description = "vpc cidr needed to determine source ip on requests"

}
