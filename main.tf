
resource "azurerm_kubernetes_cluster" "default" {
  name                = var.cluster_name
  location            = "East US"
  resource_group_name = "${var.cluster_name}-rg"
  dns_prefix          = "${var.cluster_name}-k8s"

  default_node_pool {
    name            = "${var.cluster_name}-np"
    node_count      = 1
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
    command = "./connect.sh ${var.cluster_name}-rg ${var.cluster_name}"
  }
}

resource "tanzu-mission-control_cluster" "attach_cluster_with_kubeconfig" {
  depends_on = [azurerm_kubernetes_cluster.default]
  management_cluster_name = "attached"     # Default: attached
  provisioner_name        = "attached"     # Default: attached
  name                    = var.cluster_name # Required


  attach_k8s_cluster {
    kubeconfig_file = "config-aks-cluster.yaml" # Required
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
