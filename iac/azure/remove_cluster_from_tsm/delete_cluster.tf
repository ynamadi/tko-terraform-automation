#Exchanging API token for access token
data "http" "exchange_token" {
  url             = "https://${var.vmware_cloud_host}/csp/gateway/am/api/auth/api-tokens/authorize"
  request_headers = {
    Accept       = "application/json, text/plain, */*"
    Content-Type = "application/x-www-form-urlencoded"
  }
  method       = "POST"
  request_body = "refresh_token=${var.vmw_api_token}"
}

# On infra destroy we are removing the cluster from TSM SaaS
resource "null_resource" "tsm_remove_cluster" {
  depends_on = [data.http.exchange_token]
  triggers   = {
    host         = var.tsm_host
    cluster_name = var.cluster_name
    access_token = jsondecode(data.http.exchange_token.response_body)["access_token"]
  }

  provisioner "local-exec" {
    when        = destroy
    command     = <<-EOT
      curl --location --request DELETE "https://$HOST/tsm/v1alpha1/clusters/$CLUSTER_NAME" \
      --header "csp-auth-token: $ACCESS_TOKEN" \
      --header 'content-type: application/json' \
      > destroy.json
    EOT
    environment = {
      HOST         = self.triggers.host
      CLUSTER_NAME = self.triggers.cluster_name
      ACCESS_TOKEN = self.triggers.access_token
    }
  }
}

