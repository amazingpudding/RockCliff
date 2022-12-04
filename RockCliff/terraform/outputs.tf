output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "dynamicallusers_group_id" {
  value = data.azuread_group.dynamicallusersgroup.object_id
}
