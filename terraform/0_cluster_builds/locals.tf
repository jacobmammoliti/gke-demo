locals {
  gke_clusters = yamldecode(file("${path.module}/clusters.yaml"))
}