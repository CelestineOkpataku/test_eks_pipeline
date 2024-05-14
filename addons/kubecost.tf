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

variable "kubecost_namespace" {
  type    = string
  default = "kubecost"
}

variable "kubecost_helm_chart_values" {
  type        = string
  description = "Values in raw yaml to pass to helm to override defaults in the Kubecost Helm Chart."
  default     = ""
}

variable "kubecost_helm_chart_version" {
  default     = "1.99.0"
  type        = string
  description = "The helm chart version of Kubecost. Versions can be found here https://github.com/kubecost/cost-analyzer-helm-chart/releases"
}

variable "kubecost_token" {
  default     = ""
  type        = string
  description = "A user token for Kubecost, obtained from the Kubecost organization. Can be obtained by providing email here https://kubecost.com/install"
}

variable "enable_kubecost" {
  default = true
  type    = bool
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
