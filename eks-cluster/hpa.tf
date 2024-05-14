resource "kubernetes_horizontal_pod_autoscaler" "okpataku_hpa" {
  metadata {
    name = "okpataku-c-hpa"
    namespace = "okpataku-c"
  }
  spec {
    max_replicas = 10
    min_replicas = 8
    scale_target_ref {
      kind = "Deployment"
      name = "okpataku-deployment"

    }
  }
}