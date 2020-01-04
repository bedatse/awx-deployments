provider "azuread" {
  version = "=0.7.0"
}

provider "azurerm" {
  version = "=1.39.0"
}

resource "random_password" "aks_sp_password" {
  length = 40
  special = true
  min_upper = 1
  min_lower = 1
  min_numeric = 1
  min_special = 1
}

resource "azuread_application" "aks_app" {
  name                       = var.aks_service_name
  homepage                   = "http://${var.aks_service_name}"
  identifier_uris            = ["http://${var.aks_service_name}"]
  reply_urls                 = ["http://${var.aks_service_name}"]
  available_to_other_tenants = false
  oauth2_allow_implicit_flow = true
}

resource "azuread_service_principal" "aks_sp" {
  application_id               = azuread_application.aks_app.application_id
  app_role_assignment_required = false
}

resource "azuread_service_principal_password" "aks_sp" {
  service_principal_id = azuread_service_principal.aks_sp.id
  value                = random_password.aks_sp_password.result
  end_date             = "2023-01-01T00:00:00Z"
}

resource "azurerm_resource_group" "aks" {
  name                       = "rg-${var.aks_service_name}"
  location                   = var.location
}

resource "azurerm_role_assignment" "aks" {
  scope                = azurerm_resource_group.aks.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.aks_sp.object_id
}

resource "azurerm_log_analytics_workspace" "aks" {
  name                = "log-${var.aks_service_name}"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  sku                 = "PerGB2018"
}

resource "azurerm_log_analytics_solution" "aks" {
  solution_name         = "Containers"
  location              = azurerm_resource_group.aks.location
  resource_group_name   = azurerm_resource_group.aks.name
  workspace_resource_id = azurerm_log_analytics_workspace.aks.id
  workspace_name        = azurerm_log_analytics_workspace.aks.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/Containers"
  }
}

resource "azurerm_route_table" "aks" {
  name                = "rt-${var.aks_service_name}"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
}

resource "azurerm_virtual_network" "aks" {
  name                = "vnet-${var.aks_service_name}"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  address_space       = ["10.240.0.0/16"]
}

resource "azurerm_subnet" "aks" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.aks.name
  address_prefix       = "10.240.0.0/22"
  virtual_network_name = azurerm_virtual_network.aks.name

  # this field is deprecated and will be removed in 2.0 - but is required until then
  route_table_id = azurerm_route_table.aks.id
}

resource "azurerm_subnet_route_table_association" "aks" {
  subnet_id      = azurerm_subnet.aks.id
  route_table_id = azurerm_route_table.aks.id
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-${var.aks_service_name}"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  kubernetes_version  = "1.15.5"

  dns_prefix          = "aks-${var.aks_service_name}"
  service_principal {
    client_id     = azuread_service_principal.aks_sp.application_id
    client_secret = random_password.aks_sp_password.result
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
    vnet_subnet_id = azurerm_subnet.aks.id
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

  addon_profile {
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = azurerm_log_analytics_workspace.aks.id
    }

    kube_dashboard {
      enabled                    = true
    }
  }

  role_based_access_control {
    enabled = true
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      tags,
      default_node_pool[0].node_count,
    ]
  }
}

provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.aks.kube_config.0.host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)
}

resource "kubernetes_cluster_role_binding" "default" {
  metadata {
    name = "default-admin"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "default"
    namespace = "kube-system"
  }
}

resource "kubernetes_cluster_role_binding" "k8s-dashboard" {
  metadata {
    name = "k8s-dashboard"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "kubernetes-dashboard"
    namespace = "kube-system"
  }
}
