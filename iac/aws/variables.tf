variable "tmc_host" {
  type        = string
  description = "TMC Host"
  default = "tsmentmapbu.tmc.cloud.vmware.com"
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
  default     = "test001-eks-us-east2"
}

variable "region" {
  type        = string
  sensitive   = true
  description = "AKS Cluster Name"
  default     = "us-east-2"
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
  default = "prod-4-1.nsxservicemesh.vmware.com"
  description = "Host for TSM Cloud"
}

variable "aws_control_plane_arn" {
  type        = string
  sensitive   = true
  description = "AWS ARN"
  default     = "your"
}

variable "aws_worker_arn" {
  type        = string
  sensitive   = true
  description = "AWS ARN"
  default     = "your-arn"
}

variable "tmc_credential_name" {
  type        = string
  sensitive   = true
  description = "AWS ARN"
  default     = "your-arn"
}

variable "service_cidr" {
  type        = string
  sensitive   = true
  description = "AWS ARN"
  default     = "your-arn"
}

variable "security_groups" {
  type        = list(string)
  sensitive   = true
  description = "AWS ARN"
  default     = [""]
}

variable "subnet_ids" {
  type        = list(string)
  sensitive   = true
  description = "AWS ARN"
  default     = [""]
}

variable "public_access_cidrs" {
  type        = list(string)
  sensitive   = true
  description = "AWS ARN"
  default     = [""]
}


