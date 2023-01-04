# Create Tanzu Mission Control TSM Integration resource
resource "tanzu-mission-control_integration" "create_tsm-integration" {
  depends_on = [
    azurerm_kubernetes_cluster.default,
    tanzu-mission-control_cluster_group.create_cluster_group_min_info,
    local_file.kube_config,
    tanzu-mission-control_cluster.attach_cluster_with_kubeconfig
  ]

  management_cluster_name = "attached"
  provisioner_name        = "attached"
  cluster_name            = var.cluster_name
  integration_name        = "tanzu-service-mesh"

  spec {
    configurations = jsonencode({
      enableNamespaceExclusions = true
      namespaceExclusions = [
        {
          match = "default"
          type  = "EXACT"
        }, {
          match = "kube"
          type  = "START_WITH"
        }
      ]
    })
  }
}