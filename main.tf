# Create a resource group
resource "azurerm_resource_group" "example" {
  name     = "default"
  location = "East US"
}

resource "azurerm_user_assigned_identity" "example" {
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  name = "default"
}


resource "azurerm_kubernetes_cluster" "default" {
  name                = var.cluster_name
  location            = "East US"
  resource_group_name = "default"
  dns_prefix          = "${var.cluster_name}-k8s"

  default_node_pool {
    name            = "default"
    node_count      = 2
    vm_size         = "Standard_D2_v2"
    os_disk_size_gb = 30
  }

  service_principal {
    client_id     = var.appId
    client_secret = var.password
  }

  role_based_access_control {
    enabled = true
  }

  tags = {
    environment = "Demo"
  }

  provisioner "local-exec" {
    command = <<-EOT
      export CLUSTER_NAME=${var.cluster_name}
      ./connect.sh
    EOT
  }
}

resource "tanzu-mission-control_cluster" "attach_cluster_with_kubeconfig" {
  depends_on = [azurerm_kubernetes_cluster.default]
  management_cluster_name = "attached"     # Default: attached
  provisioner_name        = "attached"     # Default: attached
  name                    = var.cluster_name # Required


  attach_k8s_cluster {
    kubeconfig_file = "config.yaml" # Required
    description     = "aks cluster"
  }

  meta {
    description = "description of the cluster"
    labels      = { "team" : "tanzu" }
  }

  spec {
    cluster_group = "default" # Default: default
  }

  ready_wait_timeout = "15m" # Default: waits until 3 min for the cluster to become ready
}
