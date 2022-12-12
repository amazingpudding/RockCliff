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

resource "azurerm_role_assignment" "dynamicgroup_to_subscription" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Virtual Machine User Login"
  principal_id         = data.azuread_group.dynamicallusersgroup.object_id
}