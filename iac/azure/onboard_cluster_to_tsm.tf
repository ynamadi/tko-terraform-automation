# Onboarding Cluster from Tanzu Service Mesh
resource "null_resource" "onboard_cluster_to_tsm" {
  depends_on = [
    azurerm_kubernetes_cluster.default,
    local_file.kube_config,
    tanzu-mission-control_cluster_group.create_cluster_group_min_info,
    tanzu-mission-control_cluster.attach_cluster_with_kubeconfig,
  ]
  triggers = {
    host         = var.tsm_host
    token        = var.vmw_api_token
    cluster_name = var.cluster_name
  }
  provisioner "local-exec" {
    command = "/bin/bash onboard-cluster-to-tsm.sh $TSM_HOST $CSP_TOKEN $CLUSTER_NAME $KUBECONFIG"

    environment = {
      TSM_HOST     = self.triggers.host
      CSP_TOKEN    = self.triggers.token
      CLUSTER_NAME = self.triggers.cluster_name
      KUBECONFIG   = base64encode(azurerm_kubernetes_cluster.default.kube_config_raw)
    }
  }
}

# Removing Cluster from Tanzu Service Mesh
resource "null_resource" "remove_cluster_from_tsm" {
  triggers = {
    host         = var.tsm_host
    token        = var.vmw_api_token
    cluster_name = var.cluster_name
    kube_config = base64encode(azurerm_kubernetes_cluster.default.kube_config_raw)
  }
  provisioner "local-exec" {
    when    = destroy
    command = "/bin/bash remove-cluster-from-tsm.sh $TSM_HOST $CSP_TOKEN $CLUSTER_NAME $KUBECONFIG"

    environment = {
      TSM_HOST     = self.triggers.host
      CSP_TOKEN    = self.triggers.token
      CLUSTER_NAME = self.triggers.cluster_name
      KUBECONFIG   = self.triggers.kube_config
    }
  }
}