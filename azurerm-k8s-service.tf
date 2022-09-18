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


resource "azurerm_kubernetes_cluster" "default" {
  depends_on          = [azurerm_resource_group.default]
  name                = var.cluster_name
  location            = "East US"
  resource_group_name = azurerm_resource_group.default.name
  dns_prefix          = "${var.cluster_name}-k8s"

  default_node_pool {
    name            = "default"
    node_count      = 2
    vm_size         = "Standard_D2_v2"
    os_disk_size_gb = 30
  }

  service_principal {
    client_id     = var.client_id
    client_secret = var.client_secret
  }

  tags = {
    environment = "Test"
  }
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.default.kube_config_raw
  sensitive = true
}

resource "local_file" "kube_config" {
  content  = azurerm_kubernetes_cluster.default.kube_config_raw
  filename = "${var.cluster_name}_config.yaml"
}