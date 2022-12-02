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

# NSG

# Firewall (req's another subnet)

# File server

# Private endpoint



# resource "azurerm_virtual_desktop_host_pool" "test" {
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name

#   name                     = "pooleddepthfirst"
#   friendly_name            = "pooleddepthfirst"
#   validate_environment     = true
#   start_vm_on_connect      = true
#   # custom_rdp_properties    = "audiocapturemode:i:1;audiomode:i:0;"
#   description              = "Acceptance Test: A pooled host pool - pooleddepthfirst"
#   type                     = "Personal"
#   load_balancer_type       = "Persistent"
#   personal_desktop_assignment_type = "Automatic"

# }

# resource "azurerm_virtual_desktop_application_group" "desktopapp" {
#   name                = "appgroupdesktop"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name

#   type          = "Desktop"
#   host_pool_id  = azurerm_virtual_desktop_host_pool.test.id
#   friendly_name = "TestAppGroup"
#   description   = "Acceptance Test: An application group"
# }