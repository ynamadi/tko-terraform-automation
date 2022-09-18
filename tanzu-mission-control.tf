#Creating a cluster group for all cluster belonging to Digital
resource "tanzu-mission-control_cluster_group" "create_cluster_group_min_info" {
  name = "digital-bu-cluster-group"
}

resource "tanzu-mission-control_cluster" "attach_cluster_with_kubeconfig" {
  depends_on = [
    azurerm_kubernetes_cluster.default,
    tanzu-mission-control_cluster_group.create_cluster_group_min_info,
    local_file.kube_config
  ]
  management_cluster_name = "attached"       # Default: attached
  provisioner_name        = "attached"       # Default: attached
  name                    = var.cluster_name # Required


  attach_k8s_cluster {
    kubeconfig_file = "${var.cluster_name}_config.yaml" # Required
    description     = "aks cluster"
  }

  meta {
    description = "description of the cluster"
    labels      = { "team" : "tanzu" }
  }

  spec {
    cluster_group = "digital-bu-cluster-group" # Default: default
  }

  ready_wait_timeout = "15m" # Default: waits until 3 min for the cluster to become ready
}
