variable "appId" {
  type = string
  description = "Azure Service Principle App Id"
}

variable "password" {
  type = string
  sensitive = true
  description = "Azure Service Principle Password"
}

variable "tenant" {
  type = string
  description = "Azure Service Principle Tenant Id"
}

variable "subscription_id" {
  type = string
  description = "Azure Service Principle Subscription Id"
}

variable "displayName" {
  type = string
  description = "Azure Service Principle display name"
}

variable "vmw_host" {
  type = string
  description = "TMC Host"
}

variable "vmw_api_token" {
  type = string
  sensitive = true
  description = "TMC API Token"
}

variable "cluster_name" {
  type = string
  sensitive = true
  description = "AKS Cluster Name"
}
