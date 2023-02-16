resource "kubernetes_service" "ingress-controller" {

    metadata {

        name      = var.name
        namespace = var.namespace

        labels = {

            app = var.name

        }

        annotations = {

            "service.beta.kubernetes.io/aws-load-balancer-type"     = "nlb"
            "service.beta.kubernetes.io/aws-load-balancer-scheme" = var.internal == true || var.internal == "true" ? "internal" : "internet-facing"

        }

    }

    spec {

        type = var.service_type

        load_balancer_source_ranges = var.service_type == "LoadBalancer" ? var.whitelist_ip_ranges : null
        load_balancer_ip            = var.service_type == "LoadBalancer" ? var.loadbalancer_ip : null

        selector = {

            app = var.name

        }

        port {

            name        = "http"
            port        = var.service_http_port
            target_port = var.http_port
            node_port   = var.node_http_port

        }

        port {

            name        = "https"
            port        = var.service_https_port
            target_port = var.https_port
            node_port   = var.node_https_port

        }

    }

}

resource "kubernetes_service" "ingress-controller-metrics" {

    metadata {

        name      = "${ var.name }-metrics"
        namespace = var.namespace

        labels = {

            app = var.name

        }

    }

    spec {

        selector = {

            app = var.name

        }

        port {

            port        = var.status_port
            target_port = var.status_port
            name        = "metrics"

        }

    }

}

resource "kubernetes_service" "default-http-backend" {

    metadata {

        name = "${ var.name }-default-http-backend"

    }

    spec {

        selector = {

            app = "${ var.name }-default-http-backend"

        }

        port {

            port        = 80
            target_port = 8080
            protocol    = "TCP"

        }

    }

}
