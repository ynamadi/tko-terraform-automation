terraform {
  required_providers {
    tanzu-mission-control = {
      source = "vmware/tanzu-mission-control"
      version = "1.0.1"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.91.0"
    }
  }
}


# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}

  # More information on the authentication methods supported by
  # the AzureRM Provider can be found here:
  # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs

  subscription_id     = var.subscription_id
  client_id           = var.appId
  client_secret       = var.password
  tenant_id           = var.tenant
}


# Create a resource group
resource "azurerm_resource_group" "default" {
  name     = "${var.cluster_name}-rg"
  location = "East US"

  tags = {
    environment = "Demo"
  }
}

resource "azurerm_user_assigned_identity" "default" {
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location

  name = "${var.cluster_name}_identify"
}

provider "tanzu-mission-control" {
  endpoint            = var.vmw_host            # optionally use TMC_ENDPOINT env var
  vmw_cloud_api_token = var.vmw_api_token# optionally use VMW_CLOUD_API_TOKEN env var

  # if you are using dev or different csp endpoint, change the default value below
  # for production environments the csp_endpoint is console.cloud.vmware.com
  # vmw_cloud_api_endpoint = "console.cloud.vmware.com" or optionally use VMW_CLOUD_ENDPOINT env var
}