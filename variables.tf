variable "image" {

    type    = string
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

    type    = map(string)
    default = null

}

variable "internal" {

    type    = bool
    default = true

}

variable "vpc_cidr" {

    type        = string
    description = "vpc cidr needed to determine source ip on requests"
    default     = null

}

variable "loadbalancer_ip" {

    type        = string
    description = "static ip for GKE"
    default     = null

}

variable "http_port" {

    type        = number
    description = "port for http"
    default     = 30080

}

variable "https_port" {

    type        = number
    description = "port for https"
    default     = 30443

}

variable "default_server_port" {

    type        = number
    description = "port for http"
    default     = null

}

variable "profiler_port" {

    type        = number
    description = "port for http"
    default     = null

}

variable "healthz_port" {

    type        = number
    description = "port for http"
    default     = null

}

variable "status_port" {

    type        = number
    description = "port for http"
    default     = null

}

variable "stream_port" {

    type        = number
    description = "port for http"
    default     = null

}

variable "service_http_port" {

    type        = number
    description = "port for http"
    default     = null

}

variable "service_https_port" {

    type        = number
    description = "port for http"
    default     = null

}

variable "node_http_port" {

    type        = number
    description = "port for http"
    default     = null

}

variable "node_https_port" {

    type        = number
    description = "port for http"
    default     = null

}

variable "ingress_class_name" {

    type        = string
    description = "ingress class name"
    default     = null

}

variable "service_type" {

    type        = string
    description = "service type"
    default     = "ClusterIP"

}
