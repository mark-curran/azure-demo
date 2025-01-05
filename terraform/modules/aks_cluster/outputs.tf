output "resource_group_name" {
  value = azurerm_resource_group.aks_cluster_rg.name
}

output "cluster_name" {
  value = azurerm_kubernetes_cluster.default.name
}
