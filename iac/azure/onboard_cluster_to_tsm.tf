#Exchanging API token for access token
data "http" "exchange_token" {
  depends_on = [null_resource.remove_cluster_from_tsm]
  url             = "https://${var.vmware_cloud_host}/csp/gateway/am/api/auth/api-tokens/authorize"
  request_headers = {
    Accept       = "application/json, text/plain, */*"
    Content-Type = "application/x-www-form-urlencoded"
  }
  method       = "POST"
  request_body = "refresh_token=${var.vmw_api_token}"
}

# Get Onboarding URL to install operator
data "http" "onboarding_url" {
  depends_on      = [data.http.exchange_token,
    null_resource.remove_cluster_from_tsm]
  url             = "https://${var.tsm_host}/tsm/v1alpha1/clusters/onboard-url"
  request_headers = {
    csp-auth-token = jsondecode(data.http.exchange_token.response_body)["access_token"]
    Accept         = "application/json, text/plain, */*"
    Content-Type   = "application/x-www-form-urlencoded"
  }
  method = "GET"
}

# Kubectl apply operator YAML to Cluster
resource "null_resource" "kubectl" {
  depends_on = [
    null_resource.remove_cluster_from_tsm,
    azurerm_kubernetes_cluster.default,
    local_file.kube_config,
    tanzu-mission-control_cluster_group.create_cluster_group_min_info,
    tanzu-mission-control_cluster.attach_cluster_with_kubeconfig,
    data.http.exchange_token,
    data.http.onboarding_url
  ]
  provisioner "local-exec" {
    command     = "kubectl apply -f ${jsondecode(data.http.onboarding_url.response_body)["url"]} --kubeconfig <(echo $KUBECONFIG | base64 --decode)"
    interpreter = ["/bin/bash", "-c"]
    environment = {
      KUBECONFIG = base64encode(azurerm_kubernetes_cluster.default.kube_config_raw)
    }
  }
}

# Onboard the cluster to TSM with configurations
resource "null_resource" "onboard_to_tsm" {
  depends_on = [
    null_resource.remove_cluster_from_tsm,
    azurerm_kubernetes_cluster.default,
    local_file.kube_config,
    tanzu-mission-control_cluster_group.create_cluster_group_min_info,
    tanzu-mission-control_cluster.attach_cluster_with_kubeconfig,
    data.http.exchange_token,
    data.http.onboarding_url,
    null_resource.kubectl
  ]

  provisioner "local-exec" {
    command = <<-EOT
      curl --location --request PUT "https://${var.tsm_host}/tsm/v1alpha1/clusters/${var.cluster_name}?createOnly=true" \
      --header "csp-auth-token: ${jsondecode(data.http.exchange_token.response_body)["access_token"]}" \
      --header 'content-type: application/json' \
      --data-raw '{"displayName": "${var.cluster_name}", "description": "Test TKG cluster", "tags": ["tf-demo"], "labels": [{"key": "Proxy Location", "value": "aviproxy"}], "autoInstallServiceMesh": true, "enableNamespaceExclusions": true, "enableInternalGateway": true, "namespaceExclusions": [{"type": "EXACT", "match": "vmware-system-tsm"}, {"type": "EXACT", "match": "vmware-system-tmc"}], "autoInstallServiceMeshConfig": {"restrictDefaultExternalAccess": false}}' \
      > token.json
    EOT
  }
}

# Parse response to extract token value
data "local_file" "token" {
  filename   = "${path.module}/token.json"
  depends_on = [null_resource.remove_cluster_from_tsm,
    null_resource.onboard_to_tsm]
}

# Create cluster-token secret to establish a secure connection between the cluster and Tanzu Service Mesh and register the cluster with Tanzu Service Mesh.
resource "null_resource" "tsm_secret" {
  depends_on = [
    null_resource.remove_cluster_from_tsm,
    azurerm_kubernetes_cluster.default,
    local_file.kube_config,
    tanzu-mission-control_cluster_group.create_cluster_group_min_info,
    tanzu-mission-control_cluster.attach_cluster_with_kubeconfig,
    data.http.exchange_token,
    data.http.onboarding_url,
    null_resource.kubectl,
    null_resource.onboard_to_tsm,
    data.local_file.token
  ]
  provisioner "local-exec" {
    command     = "kubectl -n vmware-system-tsm create secret generic cluster-token --from-literal=token=${jsondecode(data.local_file.token.content)["token"]} --kubeconfig <(echo $KUBECONFIG | base64 --decode)"
    interpreter = ["/bin/bash", "-c"]
    environment = {
      KUBECONFIG = base64encode(azurerm_kubernetes_cluster.default.kube_config_raw)
    }
  }
}

# Removing Cluster from Tanzu Service Mesh
resource "null_resource" "remove_cluster_from_tsm" {
  triggers   = {
    host         = var.tsm_host
    token         = var.vmw_api_token
    cluster_name = var.cluster_name
  }
  provisioner "local-exec" {
    when        = destroy
    command     = "/bin/bash remove-cluster-from-tsm.sh $TSM_HOST $CSP_TOKEN $CLUSTER_NAME"

    environment = {
      TSM_HOST         = self.triggers.host
      CSP_TOKEN         = self.triggers.token
      CLUSTER_NAME = self.triggers.cluster_name
    }
  }
}