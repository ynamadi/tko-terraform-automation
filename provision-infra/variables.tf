variable "client_id" {
  type        = string
  description = "Azure Service Principle App Id"
}

variable "client_secret" {
  type        = string
  sensitive   = true
  description = "Azure Service Principle Password"
}

variable "tenant_id" {
  type        = string
  description = "Azure Service Principle Tenant Id"
}

variable "subscription_id" {
  type        = string
  description = "Azure Service Principle Subscription Id"
}

variable "tmc_host" {
  type        = string
  description = "TMC Host"
  default = "tanzugreatlakesseorg.tmc.cloud.vmware.com"
}

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

variable "cluster_group_name" {
  type        = string
  description = "Logically group clusters via cluster group"
  default     = "tsm-demo"
}

variable "vmware_cloud_host" {
  type        = string
  default = "console.cloud.vmware.com"
  description = "Host for VMWare Cloud"
}

variable "tsm_host" {
  type        = string
  default = "prod-2.nsxservicemesh.vmware.com"
  description = "Host for TSM Cloud"
}