data "http" "exchange_token" {
  url             = "https://${var.vmware_cloud_host}/csp/gateway/am/api/auth/api-tokens/authorize"
  request_headers = {
    Accept       = "application/json, text/plain, */*"
    Content-Type = "application/x-www-form-urlencoded"
  }
  method       = "POST"
  request_body = "refresh_token=${var.vmw_api_token}"
}

output "access_token" {
  depends_on  = [data.http.exchange_token]
  value       = jsondecode(data.http.exchange_token.response_body)["access_token"]
  sensitive   = true
  description = "Access Token for TSM API call"
}


data "http" "onboarding_url" {
  depends_on      = [data.http.exchange_token]
  url             = "https://${var.tsm_host}/tsm/v1alpha1/clusters/onboard-url"
  request_headers = {
    csp-auth-token = jsondecode(data.http.exchange_token.response_body)["access_token"]
    Accept         = "application/json, text/plain, */*"
    Content-Type   = "application/x-www-form-urlencoded"
  }
  method = "GET"
}

output "onboarding_url" {
  depends_on  = [data.http.onboarding_url]
  value       = jsondecode(data.http.onboarding_url.response_body)["url"]
  sensitive   = true
  description = "URL for Onboarding to TSM"
}

resource "null_resource" "kubectl" {
  depends_on = [
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

data "http" "onboard_cluster_to_tsm" {
  depends_on = [
    azurerm_kubernetes_cluster.default,
    local_file.kube_config,
    tanzu-mission-control_cluster_group.create_cluster_group_min_info,
    tanzu-mission-control_cluster.attach_cluster_with_kubeconfig,
    data.http.exchange_token,
    data.http.onboarding_url,
    null_resource.kubectl
  ]
  provider = http-full
  url             = "https://${var.tsm_host}/tsm/v1alpha1/clusters/${var.cluster_name}?createOnly=true"
  request_headers = {
    csp-auth-token = jsondecode(data.http.exchange_token.response_body)["access_token"]
    Content-Type   = "application/json"
  }

  request_body = jsonencode({"displayName": var.cluster_name, "description": "Test TKG cluster", "tags": ["tf-demo"], "labels": [{"key": "Proxy Location", "value": "aviproxy"}], "autoInstallServiceMesh": true, "enableNamespaceExclusions": true, "enableInternalGateway": true, "namespaceExclusions": [{"type": "EXACT", "match": "vmware-system-tsm"}, {"type": "EXACT", "match": "vmware-system-tmc"}], "autoInstallServiceMeshConfig": {"restrictDefaultExternalAccess": false}})
  method       = "PUT"
}

output "onboard_cluster_to_tsm" {
  depends_on  = [
    azurerm_kubernetes_cluster.default,
    local_file.kube_config,
    tanzu-mission-control_cluster_group.create_cluster_group_min_info,
    tanzu-mission-control_cluster.attach_cluster_with_kubeconfig,
    data.http.exchange_token,
    data.http.onboarding_url,
    null_resource.kubectl,
    data.http.onboard_cluster_to_tsm
  ]
  value       = jsondecode(data.http.onboard_cluster_to_tsm.response_body)["token"]
  sensitive   = true
  description = "URL for Onboarding to TSM"
}

resource "null_resource" "tsm_secret" {
  depends_on = [
    azurerm_kubernetes_cluster.default,
    local_file.kube_config,
    tanzu-mission-control_cluster_group.create_cluster_group_min_info,
    tanzu-mission-control_cluster.attach_cluster_with_kubeconfig,
    data.http.exchange_token,
    data.http.onboarding_url,
    null_resource.kubectl,
    data.http.onboard_cluster_to_tsm
  ]
  provisioner "local-exec" {
    command     = "kubectl -n vmware-system-tsm create secret generic cluster-token --from-literal=token=${jsondecode(data.http.onboard_cluster_to_tsm.response_body)["token"]} --kubeconfig <(echo $KUBECONFIG | base64 --decode)"
    interpreter = ["/bin/bash", "-c"]
    environment = {
      KUBECONFIG = base64encode(azurerm_kubernetes_cluster.default.kube_config_raw)
    }
  }
}