resource "random_pet" "rg_name" {
  prefix = var.resource_group_name_prefix
}

resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = random_pet.rg_name.id
}

resource "azurerm_virtual_network" "test" {
  name                = "vdinetwork"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = var.cidr_block

  subnet {
    name           = "vditestsubnet"
    address_prefix = var.cidr_subnetblock
  }

}

resource "azurerm_role_assignment" "dynamicgroup_to_rg" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Virtual Machine User Login"
  principal_id         = data.azuread_group.dynamicallusersgroup.object_id
}

resource "azurerm_virtual_desktop_host_pool" "phxvdipool" {
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  name                     = "phxvdi"
  friendly_name            = "phxvdipool"
  custom_rdp_properties    = "audiocapturemode:i:1;audiomode:i:0;"
  description              = "Acceptance Test: A pooled host pool - pooleddepthfirst"
  type                     = "Personal"
  load_balancer_type       = "Persistent"
  personal_desktop_assignment_type  = "Direct"

}

resource "azurerm_virtual_desktop_application_group" "phxvdiappgroup" {
  name                = "phxvdiappgroup"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  type          = "Desktop"
  host_pool_id  = azurerm_virtual_desktop_host_pool.phxvdipool.id
  friendly_name = "phxvdiappgroup"
  description   = "Desktop Application Group for Phoenix Financial"
}

# NSG

# Firewall (req's another subnet)

# File server

# Private endpoint