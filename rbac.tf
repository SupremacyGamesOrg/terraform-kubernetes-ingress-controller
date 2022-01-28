resource "kubernetes_service_account" "ingress-serviceaccount" {

    metadata {

        name      = "${ var.name }-serviceaccount"
        namespace = var.namespace

    }

}

resource "kubernetes_cluster_role" "ingress-clusterrole" {

    metadata {

        name = "${ var.name }-clusterrole"

    }

    rule {

        api_groups = [ "" ]
        resources  = [ "configmaps", "endpoints", "nodes", "pods", "secrets" ]
        verbs      = [ "get", "list", "watch" ]

    }

    rule {

        api_groups = [ "" ]
        resources  = [ "configmaps" ]
        verbs      = [ "update" ]

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
        resources  = [ "ingresses", "ingresses/status", "ingressclasses" ]
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

resource "kubernetes_role" "ingress-role" {

    metadata {

        name      = "${ var.name }-role"
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

resource "kubernetes_cluster_role_binding" "ingress-clusterrole" {

    metadata {

        name = "${ var.name }-clusterrole"

    }

    role_ref {

        api_group = "rbac.authorization.k8s.io"
        kind      = "ClusterRole"
        name      = "${ var.name }-clusterrole"

    }

    subject {

        kind      = "ServiceAccount"
        name      = "${ var.name }-serviceaccount"
        namespace = var.namespace

    }

}

resource "kubernetes_role_binding" "ingress-role" {

    metadata {

        name      = "${ var.name }-role-nisa-binding"
        namespace = var.namespace

    }

    role_ref {

        api_group = "rbac.authorization.k8s.io"
        kind      = "Role"
        name      = "${ var.name }-role"

    }

    subject {

        kind      = "ServiceAccount"
        name      = "${ var.name }-serviceaccount"
        namespace = var.namespace

    }

}
