data "aws_route53_zone" "selected" {
  name         = "stevenquan.co.uk"
}


resource "kubernetes_namespace" "shc_namespace" {
  metadata {
    name = "simple-helm-chart"
    annotations = {
      "name" = "simple-helm-chart-annotation"
    }
    labels = {
      "ServiceName" = "simple-helm-chart"
    }
  }
}

resource "kubernetes_service_account" "alb_controller" {
  automount_service_account_token = true
  metadata {
    name      = "aws-alb-ingress-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = "${aws_iam_role.alb_controller.arn}"
    }
    labels = {
      "app.kubernetes.io/name"       = "aws-alb-ingress-controller"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

resource "kubernetes_cluster_role" "alb_controller" {
  metadata {
    name = "aws-alb-ingress-controller"

    labels = {
      "app.kubernetes.io/name"       = "aws-alb-ingress-controller"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  rule {
    api_groups = [
      "",
      "extensions",
    ]

    resources = [
      "configmaps",
      "endpoints",
      "events",
      "ingresses",
      "ingresses/status",
      "services",
    ]

    verbs = [
      "create",
      "get",
      "list",
      "update",
      "watch",
      "patch",
    ]
  }

  rule {
    api_groups = [
      "",
      "extensions",
    ]

    resources = [
      "nodes",
      "pods",
      "secrets",
      "services",
      "namespaces",
    ]

    verbs = [
      "get",
      "list",
      "watch",
    ]
  }
}

resource "kubernetes_cluster_role_binding" "alb_controller" {
  metadata {
    name = "aws-alb-ingress-controller"

    labels = {
      "app.kubernetes.io/name"       = "aws-alb-ingress-controller"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "alb-ingress-controller"
  }

  subject {
    api_group = ""
    kind      = "ServiceAccount"
    name      = "alb-ingress-controller"
    namespace = "kube-system"
  }
}

resource "kubernetes_deployment" "alb_controller" {
  metadata {
    name      = "alb-ingress-controller"
    namespace = "kube-system"
    labels = {
      "app.kubernetes.io/name" = "alb-ingress-controller"
    }
  }
  spec {
    strategy {
      type = "RollingUpdate"
    }
    selector {
      match_labels = {
        "app.kubernetes.io/name" = "alb-ingress-controller"
      }
    }
    template {
      metadata {
        labels = {
          "app.kubernetes.io/name" = "alb-ingress-controller"
        }
      }
      spec {
        container {
          image = "docker.io/amazon/aws-alb-ingress-controller:v1.1.8"
          name  = "alb-ingress-controller"
          args = [
            "--ingress-class=alb",
            "--cluster-name=$var.cluster_name"
          ]
        }
        automount_service_account_token = true
        service_account_name            = "aws-alb-ingress-controller"
      }
    }
  }
}

resource "kubernetes_service_account" "external_dns" {
  automount_service_account_token = true
  metadata {
    name      = "external-dns"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = "${aws_iam_role.external_dns.arn}"
    }
    labels = {
      "app.kubernetes.io/name"       = "external-dns"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

resource "kubernetes_cluster_role" "external_dns" {
  metadata {
    name = "external-dns"

    labels = {
      "app.kubernetes.io/name"       = "external-dns"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  rule {
    api_groups = [
      "",
    ]
    resources = [
      "services",
      "pods",
      "nodes",
    ]
    verbs = [
      "get",
      "watch",
      "list",
    ]
  }

  rule {
    api_groups = [
      "extensions",
    ]
    resources = [
      "ingresses",
    ]
    verbs = [
      "get",
      "list",
      "watch",
    ]
  }
}

resource "kubernetes_cluster_role_binding" "external_dns" {
  metadata {
    name = "external-dns-viewer"

    labels = {
      "app.kubernetes.io/name"       = "external-dns-viewer"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "external-dns"
  }

  subject {
    api_group = ""
    kind      = "ServiceAccount"
    name      = "external-dns"
    namespace = "kube-system"
  }
}

resource "kubernetes_deployment" "external_dns" {
  metadata {
    name      = "external-dns"
    namespace = "kube-system"
    labels = {
      "app.kubernetes.io/name" = "external-dns"
    }
  }
  spec {
    strategy {
      type = "Recreate"
    }
    selector {
      match_labels = {
        "app.kubernetes.io/name" = "external-dns"
      }
    }
    template {
      metadata {
        labels = {
          "app.kubernetes.io/name" = "external-dns"
        }
      }
      spec {
        container {
          image = "k8s.gcr.io/external-dns/external-dns:v0.7.3"
          name  = "external-dns"
          args = [
            "--source=service",
            "--source=ingress",
            "--provider=aws",
            "--aws-zone-type=public",
            "--registry=txt",
            "--txt-owner-id=${data.aws_route53_zone.selected.zone_id}"
          ]
        }
        automount_service_account_token = true
        service_account_name            = "external-dns"
      }
    }
  }
}

resource "kubernetes_service_account" "metrics_server" {
  automount_service_account_token = true
  metadata {
    name      = "metrics-server"
    namespace = "kube-system"
    labels = {
      "app.kubernetes.io/name"       = "metrics-server"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

resource "kubernetes_cluster_role" "metrics_reader" {
  metadata {
    name = "system:aggregated-metrics-reader"

    labels = {
      "rbac.authorization.k8s.io/aggregate-to-view" = "true"
      "rbac.authorization.k8s.io/aggregate-to-edit" = "true"
      "rbac.authorization.k8s.io/aggregate-to-edit" = "true"
      "rbac.authorization.k8s.io/aggregate-to-admin" = "true"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  rule {
    api_groups = [
      "metrics.k8s.io",
    ]
    resources = [
      "pods",
      "nodes",
    ]
    verbs = [
      "get",
      "watch",
      "list",
    ]
  }
}

resource "kubernetes_cluster_role_binding" "metrics_auth_delegator" {
  metadata {
    name = "metrics-server:system:auth-delegator"

    labels = {
      "app.kubernetes.io/name"       = "metrics-server-auth-delegator"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "system:auth-delegator"
  }

  subject {
    api_group = ""
    kind      = "ServiceAccount"
    name      = "metrics-server"
    namespace = "kube-system"
  }
}

resource "kubernetes_cluster_role" "metrics_server" {
  metadata {
    name = "system:metrics-server"

    labels = {
      "app.kubernetes.io/name"       = "metrics-serverr"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  rule {
    api_groups = [
      "",
    ]
    resources = [
      "pods",
      "nodes",
      "nodes/stats",
      "namespaces",
      "configmaps",
    ]
    verbs = [
      "get",
      "watch",
      "list",
    ]
  }
}

resource "kubernetes_cluster_role_binding" "metrics_server" {
  metadata {
    name = "system:metrics-server"

    labels = {
      "app.kubernetes.io/name"       = "metrics-serverr"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "system:metrics-server"
  }

  subject {
    api_group = ""
    kind      = "ServiceAccount"
    name      = "metrics-server"
    namespace = "kube-system"
  }
}

resource "kubernetes_role_binding" "metrics_auth_reader" {
  metadata {
    name      = "metrics-server-auth-reader"
    namespace = "kube-system"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "extension-apiserver-authentication-reader"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "metrics-server"
    namespace = "kube-system"
  }
}

resource "kubernetes_service" "metric_server" {
  metadata {
    name = "metrics-server"
    namespace = "kube-system"
    labels = {
      "kubernetes.io/name" = "Metrics-server"
      "kubernetes.io/cluster-service" = "true"
    }
  }
  spec {
    selector = {
      "k8s-app" = "metrics-server"
    }
    session_affinity = "ClientIP"
    port {
      port        = "443"
      protocol    = "TCP"
      target_port = "main-port"
    }
  }
}

resource "kubernetes_deployment" "metrics_server" {
  metadata {
    name      = "metrics-server"
    namespace = "kube-system"
    labels = {
      "app.kubernetes.io/name" = "metrics-server"
    }
  }
  spec {
    strategy {
      type = "Recreate"
    }
    selector {
      match_labels = {
        "k8s-app" = "metrics-server"
      }
    }
    template {
      metadata {
        name = "metrics-server"
        labels = {
          "k8s-app" = "metrics-server"
        }
      }
      spec {
        service_account_name = "metrics-server"
        volume {
          name = "tmp-dir"
          empty_dir {}
        }
        container {
          image = "k8s.gcr.io/metrics-server/metrics-server:v0.3.7"
          name  = "metrics-server"
          image_pull_policy = "IfNotPresent"
          args = [
            "--cert-dir=/tmp",
            "--secure-port=4443",
          ]
        port {
          name = "main-port"
          container_port = "4443"
          protocol = "TCP"
         }
        security_context {
          read_only_root_filesystem = true
          run_as_non_root = true
          run_as_user = "1000"
         }
        volume_mount {
          name = "tmp-dir"
          mount_path = "/tmp"
         }
        }
        node_selector = {
          "kubernetes.io/os" = "linux"
        }
      } 
    }
  }
}

resource "kubernetes_api_service" "metric_server" {
  metadata {
    name = "v1beta1.metrics.k8s.io"
  }
  spec {
    service {
      name = "metrics-server"
      namespace = "kube-system"
    }
    group = "metrics.k8s.io"
    version = "v1beta1"
    insecure_skip_tls_verify = true
    group_priority_minimum = "100"
    version_priority = "100"
  }
}