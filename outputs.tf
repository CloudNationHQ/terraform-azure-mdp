output "config" {
  description = "contains managed devops pool configuration"
  value       = azurerm_managed_devops_pool.this
}

output "dev_center" {
  description = "contains dev center configuration"
  value       = azurerm_dev_center.this
}

output "dev_center_project" {
  description = "contains dev center project configuration"
  value       = azurerm_dev_center_project.this
}
