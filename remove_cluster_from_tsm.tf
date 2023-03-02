#data "http" "exchange_token_remove" {
#  url             = "https://${var.vmware_cloud_host}/csp/gateway/am/api/auth/api-tokens/authorize"
#  request_headers = {
#    Accept       = "application/json, text/plain, */*"
#    Content-Type = "application/x-www-form-urlencoded"
#  }
#  method       = "POST"
#  request_body = "refresh_token=${var.vmw_api_token}"
#}
#
#output "access_token_for_remove" {
#  depends_on  = [data.http.exchange_token_remove]
#  value       = jsondecode(data.http.exchange_token_remove.response_body)["access_token"]
#  sensitive   = true
#  description = "Access Token for TSM API call"
#}
#
#locals {
#  access_token_for_remove = jsondecode(data.http.exchange_token_remove.response_body)["access_token"]
#}
#
#data "http" "exchange_token_remove" {
#  url             = "https://${var.tsm_host}/tsm/v1alpha1/clusters/${var.cluster_name}"
#  request_headers = {
#    Content-Type       = "application/json"
#    "csp-auth-token" = local.access_token_for_remove
#  }
#  method       = "DELETE"
#}