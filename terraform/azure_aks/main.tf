provider "azuread" {
  version = "=0.7.0"
}

provider "azurerm" {
  version = "=1.39.0"
}

resource "azuread_application" "aks" {
  name                       = var.aks_service_name
  homepage                   = "http://${var.aks_service_name}"
  identifier_uris            = ["http://${var.aks_service_name}"]
  reply_urls                 = ["http://${var.aks_service_name}"]
  available_to_other_tenants = false
  oauth2_allow_implicit_flow = true
}

resource "azuread_service_principal" "aks" {
  application_id               = azuread_application.aks.application_id
  app_role_assignment_required = false
}

# resource "azurerm_resource_group" "aks" {
#   name                       = "rg-${var.aks_service_name}"
#   location                   = var.location
# }

# resource "azurerm_role_assignment" "aks" {
#   scope                = azurerm_resource_group.aks.id
#   role_definition_name = "Contributor"
#   principal_id         = var.kubernetes_sp_object_id
# }

# resource "azurerm_log_analytics_workspace" "aks" {
#   name                = "log-${var.aks_service_name}"
#   location            = azurerm_resource_group.aks.location
#   resource_group_name = azurerm_resource_group.aks.name
#   sku                 = "PerGB2018"
# }

# resource "azurerm_log_analytics_solution" "aks" {
#   solution_name         = "Containers"
#   location              = azurerm_resource_group.aks.location
#   resource_group_name   = azurerm_resource_group.aks.name
#   workspace_resource_id = azurerm_log_analytics_workspace.aks.id
#   workspace_name        = azurerm_log_analytics_workspace.aks.name

#   plan {
#     publisher = "Microsoft"
#     product   = "OMSGallery/Containers"
#   }
# }

# resource "azurerm_route_table" "aks" {
#   name                = "rt-${var.aks_service_name}"
#   location            = azurerm_resource_group.aks.location
#   resource_group_name = azurerm_resource_group.aks.name

#   # TODO: Figure out what values to fill in
#   # route {
#   #   name                   = "default"
#   #   address_prefix         = "10.100.0.0/14"
#   #   next_hop_type          = "VirtualAppliance"
#   #   next_hop_in_ip_address = "10.10.1.1"
#   # }
# }

# resource "azurerm_virtual_network" "aks" {
#   name                = "vnet-${var.aks_service_name}"
#   location            = azurerm_resource_group.aks.location
#   resource_group_name = azurerm_resource_group.aks.name
#   address_space       = ["10.240.0.0/16"]
# }

# resource "azurerm_subnet" "aks" {
#   name                 = "internal"
#   resource_group_name  = azurerm_resource_group.aks.name
#   address_prefix       = "10.240.0.0/22"
#   virtual_network_name = azurerm_virtual_network.aks.name

#   # this field is deprecated and will be removed in 2.0 - but is required until then
#   route_table_id = azurerm_route_table.aks.id
# }

# resource "azurerm_subnet_route_table_association" "aks" {
#   subnet_id      = azurerm_subnet.aks.id
#   route_table_id = azurerm_route_table.aks.id
# }

# resource "azurerm_kubernetes_cluster" "aks" {
#   name                = "aks-${var.aks_service_name}"
#   location            = azurerm_resource_group.aks.location
#   resource_group_name = azurerm_resource_group.aks.name

#   dns_prefix          = "aks-${var.aks_service_name}"
#   service_principal {
#     client_id     = var.kubernetes_client_id
#     client_secret = var.kubernetes_client_secret
#   }

#   default_node_pool {
#     name                    = "default"

#     vm_size                 = "Standard_B2ms"
#     os_disk_size_gb         = "50"

#     type                    = "VirtualMachineScaleSets"
#     enable_auto_scaling     = true
#     node_count              = "1"
#     max_count               = "3"
#     min_count               = "1"

#     # Required for advanced networking
#     vnet_subnet_id = azurerm_subnet.aks.id
#   }

#   linux_profile {
#     admin_username = "aksadmin"

#     ssh_key {
#       key_data = var.ssh_key
#     }
#   }

#   network_profile {
#     network_plugin = "azure"
#   }

#   addon_profile {
#     oms_agent {
#       enabled                    = true
#       log_analytics_workspace_id = azurerm_log_analytics_workspace.aks.id
#     }

#     kube_dashboard {
#       enabled                    = true
#     }
#   }

#   role_based_access_control {
#     enabled = true
#   }

#   tags = var.tags

#   lifecycle {
#     ignore_changes = [
#       # Ignore changes to tags, e.g. because a management agent
#       # updates these based on some ruleset managed elsewhere.
#       tags,
#       default_node_pool[0].node_count,
#     ]
#   }
# }
