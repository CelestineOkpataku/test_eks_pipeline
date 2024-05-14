resource "kubernetes_namespace" "example" {
  metadata {
    annotations = {
      name = "okpataku-c"
    }

    labels = {
      mylabel = "okpataku"
    }

    name = "okpataku-c"
  }
}