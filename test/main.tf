provider "kubernetes" {

    config_path = "~/.kube/config"

}

module "test" {

    source = "../"

    name          = "ingress-controller-ops"
    namespace     = "default"
    node_selector = {

        role = "infra"
    }

    ingress_class_name  = "ops"
    http_port           = 30001
    https_port          = 30002
    default_server_port = 30003
    profiler_port       = 30004
    healthz_port        = 30005
    status_port         = 30006
    stream_port         = 30007
    service_http_port   = 30008
    service_https_port  = 30009

}
