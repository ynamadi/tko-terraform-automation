terraform {
  required_providers {
    tanzu-mission-control = {
      source  = "vmware/tanzu-mission-control"
      version = "1.1.5"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.43.0"
    }
    http = {
      source = "hashicorp/http"
      version = "3.2.1"
    }
    local = {
      source = "hashicorp/local"
    }
    restapi = {
      source = "Mastercard/restapi"
      version = "1.18.0"
    }
  }
}


# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}

  # More information on the authentication methods supported by
  # the AzureRM Provider can be found here:
  # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs

  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}

provider "tanzu-mission-control" {
  endpoint            = var.tmc_host      # optionally use TMC_ENDPOINT env var
  vmw_cloud_api_token = var.vmw_api_token # optionally use VMW_CLOUD_API_TOKEN env var

  # if you are using dev or different csp endpoint, change the default value below
  # for production environments the csp_endpoint is console.cloud.vmware.com
  # vmw_cloud_api_endpoint = "console.cloud.vmware.com" or optionally use VMW_CLOUD_ENDPOINT env var
}

