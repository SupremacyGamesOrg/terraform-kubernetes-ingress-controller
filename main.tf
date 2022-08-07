resource "kubernetes_config_map" "nginx-configuration" {

    metadata {

        name      = "${ var.name }-configuration"
        namespace = var.namespace

        labels = {

            app = var.name

        }

    }

    data = {

        proxy-connect-timeout = 600
        proxy-read-timeout    = 600
        body-size             = "1024m"
        use-forwarded-headers = true
        proxy-body-size       = "1024m"
        server-tokens         = false
        use-gzip              = true
        proxy-real-ip-cidr    = var.vpc_cidr

    }

}

resource "kubernetes_daemonset" "ingress-controller" {

    depends_on = [ kubernetes_service.default-http-backend ]

    metadata {

        name      = var.name
        namespace = var.namespace

        labels = {

            app = var.name

        }

    }

    spec {

        selector {

            match_labels = {

                app = var.name

            }

        }

        template {

            metadata {

                labels = {

                    app = var.name

                }

                annotations = {

                    "prometheus.io/scrape" = true
                    "promethus.io/port"    = var.healthz_port

                }

            }

            spec {

                service_account_name             = "${ var.name }-serviceaccount"
                automount_service_account_token  = true
                termination_grace_period_seconds = 1
                host_network                     = true
                node_selector                    = var.node_selector

                container {

                    name  = var.name
                    image = "quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.33.0"
                    #                    image = "k8s.gcr.io/ingress-nginx/controller:v1.1.1"

                    args = concat([

                        "/nginx-ingress-controller",
                        #                        "--default-backend-service=$(POD_NAMESPACE)/default-http-backend",
                        "--configmap=$(POD_NAMESPACE)/nginx-configuration",
                        "--annotations-prefix=nginx.ingress.kubernetes.io",
                        "--ingress-class=${ var.ingress_class_name }",
                        "--http-port=${ var.http_port }",
                        "--https-port=${ var.https_port }",
                        "--default-server-port=${ var.default_server_port }",
                        "--profiler-port=${ var.profiler_port }",
                        "--healthz-port=${ var.healthz_port }",
                        "--status-port=${ var.status_port }",
                        "--stream-port=${ var.stream_port }"

                    ], var.additional_args)

                    readiness_probe {

                        http_get {

                            path   = "/healthz"
                            port   = var.healthz_port
                            scheme = "HTTP"

                        }

                        initial_delay_seconds = 5
                        timeout_seconds       = 3

                    }

                    liveness_probe {

                        http_get {

                            path   = "/healthz"
                            port   = var.healthz_port
                            scheme = "HTTP"

                        }

                        initial_delay_seconds = 5
                        timeout_seconds       = 3

                    }

                    port {

                        container_port = var.node_http_port
                        host_port      = var.node_http_port

                    }

                    port {

                        container_port = var.node_https_port
                        host_port      = var.node_https_port

                    }

                    port {

                        container_port = var.status_port
                        host_port      = var.status_port

                    }

                    env {

                        name = "POD_NAME"

                        value_from {

                            field_ref {

                                field_path = "metadata.name"

                            }

                        }

                    }

                    env {

                        name = "POD_NAMESPACE"

                        value_from {

                            field_ref {

                                field_path = "metadata.namespace"

                            }

                        }

                    }

                }

            }

        }

    }

}

resource "kubernetes_deployment" "default-http-backend" {

    metadata {

        name      = "${ var.name }-default-http-backend"
        namespace = var.namespace

        labels = {

            app = "${ var.name }-default-http-backend"

        }

    }

    spec {

        replicas = 1

        selector {

            match_labels = {

                app = "${ var.name }-default-http-backend"

            }

        }

        template {

            metadata {

                labels = {

                    app = "${ var.name }-default-http-backend"

                }

            }

            spec {

                node_selector = var.node_selector

                container {

                    name  = "${ var.name }-default-http-backend"
                    image = "gcr.io/google_containers/defaultbackend:1.0"

                    liveness_probe {

                        http_get {

                            path   = "/healthz"
                            port   = 8080
                            scheme = "HTTP"

                        }

                        initial_delay_seconds = 10
                        timeout_seconds       = 5

                    }

                    readiness_probe {

                        http_get {

                            path   = "/healthz"
                            port   = 8080
                            scheme = "HTTP"

                        }

                        initial_delay_seconds = 10
                        timeout_seconds       = 5

                    }

                    port {

                        container_port = 8080

                    }

                    resources {

                        requests = {

                            cpu    = "10m"
                            memory = "20Mi"

                        }

                        limits = {

                            cpu    = "10m"
                            memory = "20Mi"

                        }

                    }

                }

            }

        }

    }

}

#resource "kubernetes_manifest" "ingress-class" {
#
#    manifest = {
#
#        apiVersion = "networking.k8s.io/v1"
#        kind       = "IngressClass"
#
#        metadata = {
#
#            name = var.ingress_class_name
#
#        }
#
#        spec = {
#
#            controller = var.name
#
#            #            parameters = {
#            #
#            #                apiGroup = "ops.mlfabric.ai"
#            #                kind     = "IngressParameters"
#            #                name     = var.ingress_class_name
#            #
#            #            }
#
#        }
#
#    }
#
#}
