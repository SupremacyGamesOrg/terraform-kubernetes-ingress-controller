variable "cluster_name" {

    type = string
    description = "name of the eks cluster"

}

variable "image" {

    type = string
    default = "quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.33.0"

}

variable "aws_profile" {

    type = string
    default = null

}

variable "aws_access_key_id" {

    type = string
    default = null

}

variable "aws_secret_access_key" {

    type = string
    default = null

}

variable "aws_region" {

    type = string

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
