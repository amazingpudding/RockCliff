output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "avd_pool_name" {
  value = azurerm_virtual_desktop_host_pool.test.name
}

output "dag_name" {
  value = azurerm_virtual_desktop_application_group.desktopapp.name
}