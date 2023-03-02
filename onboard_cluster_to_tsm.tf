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

locals {
  access_token = jsondecode(data.http.exchange_token.response_body)["access_token"]
}

provider "restapi" {

  uri                  = "https://${var.tsm_host}"
  write_returns_object = true
  debug                = true

  headers = {
    "csp-auth-token" = local.access_token
  }

  create_method  = "PUT"
  update_method  = "PUT"
  destroy_method = "PUT"
}

resource "restapi_object" "put_request" {
  depends_on  = [
    data.http.exchange_token,
    data.http.onboarding_url,
    null_resource.kubectl
  ]

  path = "/tsm/v1alpha1/clusters/${var.cluster_name}?createOnly=true"
  data = "{\n    \"displayName\": \"${var.cluster_name}\",\n    \"description\": \"Test TKG cluster\",\n    \"tags\": [\n        \"tf-demo\"\n    ],\n    \"labels\": [\n        {\n            \"key\": \"Proxy Location\",\n            \"value\": \"aviproxy\"\n        }\n    ],\n    \"autoInstallServiceMesh\": true,\n    \"enableNamespaceExclusions\": true,\n    \"enableInternalGateway\": true,\n    \"namespaceExclusions\": [\n        {\n            \"type\": \"EXACT\",\n            \"match\": \"vmware-system-tsm\"\n        },\n        {\n            \"type\": \"EXACT\",\n            \"match\": \"vmware-system-tmc\"\n        }\n    ],\n    \"autoInstallServiceMeshConfig\": {\n        \"restrictDefaultExternalAccess\": false\n    }\n}"
}


output "token" {
  depends_on = [
    azurerm_kubernetes_cluster.default,
    local_file.kube_config,
    data.http.exchange_token,
    data.http.onboarding_url,
    restapi_object.put_request
  ]

  value       = jsondecode(restapi_object.put_request.api_response)["token"]
  sensitive   = true
  description = "Onboarding to TSM response"
}


resource "null_resource" "tsm_secret" {
  depends_on = [
    azurerm_kubernetes_cluster.default,
    local_file.kube_config,
    data.http.exchange_token,
    data.http.onboarding_url,
    null_resource.kubectl,
    restapi_object.put_request
  ]
  provisioner "local-exec" {
    command     = "kubectl -n vmware-system-tsm create secret generic cluster-token --from-literal=token=${jsondecode(restapi_object.put_request.api_response)["token"]} --kubeconfig <(echo $KUBECONFIG | base64 --decode)"
    interpreter = ["/bin/bash", "-c"]
    environment = {
      KUBECONFIG = base64encode(azurerm_kubernetes_cluster.default.kube_config_raw)
    }
  }
}
