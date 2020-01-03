# Replace AKS Module with Terraform native resources for AKS

resource "azurerm_resource_group" "awx" {
  name     = "rg-${var.awx_service_name}"
  location = var.location
}

resource "azurerm_route_table" "awx" {
  name                = "rt-${var.awx_service_name}"
  location            = azurerm_resource_group.awx.location
  resource_group_name = azurerm_resource_group.awx.name

  # TODO: Figure out what values to fill in
  # route {
  #   name                   = "default"
  #   address_prefix         = "10.100.0.0/14"
  #   next_hop_type          = "VirtualAppliance"
  #   next_hop_in_ip_address = "10.10.1.1"
  # }
}

resource "azurerm_virtual_network" "awx" {
  name                = "vnet-${var.awx_service_name}"
  location            = azurerm_resource_group.awx.location
  resource_group_name = azurerm_resource_group.awx.name
  address_space       = ["10.240.0.0/16"]
}

resource "azurerm_subnet" "awx" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.awx.name
  address_prefix       = "10.240.0.0/22"
  virtual_network_name = azurerm_virtual_network.awx.name

  # this field is deprecated and will be removed in 2.0 - but is required until then
  route_table_id = azurerm_route_table.awx.id
}

resource "azurerm_subnet_route_table_association" "awx" {
  subnet_id      = azurerm_subnet.awx.id
  route_table_id = azurerm_route_table.awx.id
}

resource "azurerm_kubernetes_cluster" "awx" {
  name                = "aks-${var.awx_service_name}"
  location            = azurerm_resource_group.awx.location
  resource_group_name = azurerm_resource_group.awx.name

  dns_prefix          = "aks-${var.awx_service_name}"
  service_principal {
    client_id     = var.kubernetes_client_id
    client_secret = var.kubernetes_client_secret
  }

  default_node_pool {
    name                    = "default"

    vm_size                 = "Standard_B2ms"
    os_disk_size_gb         = "50"

    type                    = "VirtualMachineScaleSets"
    enable_auto_scaling     = true
    node_count              = "1"
    max_count               = "3"
    min_count               = "1"

    # Required for advanced networking
    vnet_subnet_id = azurerm_subnet.awx.id
  }

  linux_profile {
    admin_username = "aksadmin"

    ssh_key {
      key_data = var.ssh_key
    }
  }

  network_profile {
    network_plugin = "azure"
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      tags,
      default_node_pool["node_count"],
    ]
  }
}

# provider "kubernetes" {
#   host                   = azurerm_kubernetes_cluster.awx.kube_config.0.host
#   username               = azurerm_kubernetes_cluster.awx.kube_config.0.username
#   password               = azurerm_kubernetes_cluster.awx.kube_config.0.password
#   client_certificate     = base64decode(azurerm_kubernetes_cluster.awx.kube_config.0.client_certificate)
#   client_key             = base64decode(azurerm_kubernetes_cluster.awx.kube_config.0.client_key)
#   cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.awx.kube_config.0.cluster_ca_certificate)
# }

provider "helm" {
  kubernetes {
    host                   = azurerm_kubernetes_cluster.awx.kube_config.0.host
    username               = azurerm_kubernetes_cluster.awx.kube_config.0.username
    password               = azurerm_kubernetes_cluster.awx.kube_config.0.password
    client_certificate     = base64decode(azurerm_kubernetes_cluster.awx.kube_config.0.client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.awx.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.awx.kube_config.0.cluster_ca_certificate)
  }
}

resource "helm_release" "awx" {
  name    = "awx"
  repository = "https://honestica.github.io/lifen-charts/"
  chart   = "lifen/awx"
  version = "1.0.0"
}
