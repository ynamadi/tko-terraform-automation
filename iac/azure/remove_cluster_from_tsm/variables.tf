variable "vmw_api_token" {
  type        = string
  sensitive   = true
  description = "TMC API Token"
}

variable "cluster_name" {
  type        = string
  sensitive   = true
  description = "AKS Cluster Name"
  default     = "test001"
}

variable "vmware_cloud_host" {
  type        = string
  default = "console.cloud.vmware.com"
  description = "Host for VMWare Cloud"
}

variable "tsm_host" {
  type        = string
  default = "prod-4.nsxservicemesh.vmware.com"
  description = "Host for TSM Cloud"
}