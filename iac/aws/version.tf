terraform {
  required_providers {
    tanzu-mission-control = {
      source  = "vmware/tanzu-mission-control"
      version = "1.1.7"
    }
  }
}

provider "tanzu-mission-control" {
  endpoint            = var.tmc_host
  vmw_cloud_api_token = var.vmw_api_token
  vmw_cloud_api_endpoint = var.vmware_cloud_host
}