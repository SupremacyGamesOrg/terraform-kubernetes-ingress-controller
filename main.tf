resource "kubernetes_config_map" "nginx-configuration" {

    metadata {

        name      = "nginx-configuration"
        namespace = var.namespace

        labels = {

            app = "ingress-controller"

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
                    "promethus.io/port"    = 10254

                }

            }

            spec {

                service_account_name             = "nginx-ingress-serviceaccount"
                automount_service_account_token  = true
                termination_grace_period_seconds = 1
                host_network                     = true
                node_selector                    = var.node_selector

                container {

                    name  = var.name
                    image = "quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.33.0"

                    args = [

                        "/nginx-ingress-controller",
                        "--default-backend-service=$(POD_NAMESPACE)/default-http-backend",
                        "--configmap=$(POD_NAMESPACE)/nginx-configuration",
                        "--annotations-prefix=nginx.ingress.kubernetes.io"

                    ]

                    readiness_probe {

                        http_get {

                            path   = "/healthz"
                            port   = 10254
                            scheme = "HTTP"

                        }

                        initial_delay_seconds = 15
                        timeout_seconds       = 3

                    }

                    liveness_probe {

                        http_get {

                            path   = "/healthz"
                            port   = 10254
                            scheme = "HTTP"

                        }

                        initial_delay_seconds = 15
                        timeout_seconds       = 3

                    }

                    port {

                        container_port = 80
                        host_port      = 80

                    }

                    port {

                        container_port = 443
                        host_port      = 443

                    }

                    port {

                        container_port = 10254
                        host_port      = 10254

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

resource "kubernetes_service" "ingres-controller" {

    metadata {

        name      = var.name
        namespace = var.namespace

        labels = {

            app = var.name

        }

        annotations = {

            "service.beta.kubernetes.io/aws-load-balancer-type"     = "nlb"
            "service.beta.kubernetes.io/aws-load-balancer-internal" = var.internal == true || var.internal == "true" ? "true" : null

        }

    }

    spec {

        type = "LoadBalancer"

        selector = {

            app = var.name

        }

        port {

            port        = 80
            target_port = 80
            node_port   = 30080
            name        = "http"

        }

        port {

            port        = 443
            target_port = 443
            node_port   = 30443
            name        = "https"

        }

        load_balancer_source_ranges = var.whitelist_ip_ranges

        loadBalancerIP = var.loadbalancer_ip
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

            port        = 10254
            target_port = 10254
            name        = "metrics"

        }

    }

}

resource "kubernetes_deployment" "default-http-backend" {

    metadata {

        name      = "default-http-backend"
        namespace = var.namespace

        labels = {

            app = "default-http-backend"

        }

    }

    spec {

        replicas = 1

        selector {

            match_labels = {

                app = "default-http-backend"

            }

        }

        template {

            metadata {

                labels = {

                    app = "default-http-backend"

                }

            }

            spec {

                node_selector = var.node_selector

                container {

                    name  = "default-http-backend"
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

                        requests {

                            cpu    = "10m"
                            memory = "20Mi"

                        }

                        limits {

                            cpu    = "10m"
                            memory = "20Mi"

                        }

                    }

                }

            }

        }

    }

}

resource "kubernetes_service" "default-http-backend" {

    metadata {

        name = "default-http-backend"

    }

    spec {

        selector = {

            app = "default-http-backend"

        }

        port {

            port        = 80
            target_port = 8080
            protocol    = "TCP"

        }

    }

}

resource "kubernetes_service_account" "nginx-ingress-serviceaccount" {

    metadata {

        name      = "nginx-ingress-serviceaccount"
        namespace = var.namespace

    }

}

resource "kubernetes_cluster_role" "nginx-ingress-clusterrole" {

    metadata {

        name = "nginx-ingress-clusterrole"

    }

    rule {

        api_groups = [ "" ]
        resources  = [ "configmaps", "endpoints", "nodes", "pods", "secrets" ]
        verbs      = [ "get", "list", "watch" ]

    }

    rule {

        api_groups = [ "" ]
        resources  = [ "nodes" ]
        verbs      = [ "get" ]

    }

    rule {

        api_groups = [ "" ]
        resources  = [ "services" ]
        verbs      = [ "get", "list", "watch" ]

    }

    rule {

        api_groups = [ "extensions", "networking.k8s.io" ]
        resources  = [ "ingresses", "ingresses/status" ]
        verbs      = [ "get", "list", "watch", "update" ]

    }

    rule {

        api_groups = [ "" ]
        resources  = [ "events" ]
        verbs      = [ "create", "patch" ]

    }

    rule {

        api_groups = [ "extensions" ]
        resources  = [ "ingresses/status" ]
        verbs      = [ "update" ]

    }

}

resource "kubernetes_role" "nginx-ingress-role" {

    metadata {

        name      = "nginx-ingress-role"
        namespace = var.namespace

    }

    rule {

        api_groups = [ "" ]
        resources  = [ "configmaps", "pods", "secrets", "namespaces" ]
        verbs      = [ "get" ]

    }

    rule {

        api_groups     = [ "" ]
        resources      = [ "configmaps" ]
        resource_names = [ "ingress-controller-leader-nginx" ]
        verbs          = [ "get", "update" ]

    }

    rule {

        api_groups = [ "" ]
        resources  = [ "configmaps", "endpoints" ]
        verbs      = [ "create" ]

    }

    rule {

        api_groups = [ "" ]
        resources  = [ "endpoints" ]
        verbs      = [ "get" ]

    }

}

resource "kubernetes_cluster_role_binding" "nginx-ingress-clusterrole" {

    metadata {

        name = "nginx-ingress-clusterrole"

    }

    role_ref {

        api_group = "rbac.authorization.k8s.io"
        kind      = "ClusterRole"
        name      = "nginx-ingress-clusterrole"

    }

    subject {

        kind      = "ServiceAccount"
        name      = "nginx-ingress-serviceaccount"
        namespace = var.namespace

    }

}

resource "kubernetes_role_binding" "nginx-ingress-role" {

    metadata {

        name      = "nginx-ingress-role-nisa-binding"
        namespace = var.namespace

    }

    role_ref {

        api_group = "rbac.authorization.k8s.io"
        kind      = "Role"
        name      = "nginx-ingress-role"

    }

    subject {

        kind      = "ServiceAccount"
        name      = "nginx-ingress-serviceaccount"
        namespace = var.namespace

    }

}
