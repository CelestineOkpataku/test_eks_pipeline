resource "kubernetes_namespace" "kubecost" {
  count = var.enable_kubecost ? 1 : 0
  metadata {
    name = var.kubecost_namespace
  }
}

resource "helm_release" "kubecost" {
  count      = var.enable_kubecost ? 1 : 0
  name       = "kubecost"
  version    = var.kubecost_helm_chart_version
  chart      = "cost-analyzer"
  repository = "https://kubecost.github.io/cost-analyzer/"
  namespace  = kubernetes_namespace.kubecost.0.metadata.0.name
  wait       = true

  values = [
    var.kubecost_helm_chart_values,
    # Add configuration to disable PodSecurityPolicy
    <<EOF
    disablePodSecurityPolicy: true
    EOF
  ]


  set {
    name  = "kubecostToken"
    value = var.kubecost_token
  }
}


resource "helm_release" "nginx_ingress" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = var.namespace
  create_namespace = var.create_namespace

  provisioner "local-exec" {
    command = <<EOF
      echo "Waiting for the nginx ingress controller pods"
      kubectl wait --namespace ingress \
      --for=condition=ready pod \
      --selector=app.kubernetes.io/component=controller \
      --timeout=120s
      echo "Nginx ingress controller successfully started"
    EOF
  }
}

variable "namespace" {
  default     = "ingress"
  description = "What namespace to create controller in."
  type        = string
}

variable "create_namespace" {
  type        = bool
  default     = true
  description = "Whether to create namespace if it doesn't exist."
}
