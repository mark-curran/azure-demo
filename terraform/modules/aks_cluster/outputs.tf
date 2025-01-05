output "resource_group_name" {
  value = azurerm_resource_group.aks_cluster_rg.name
}

output "cluster_name" {
  value = azurerm_kubernetes_cluster.default.name
}

output "kube_config_raw" {
  value = azurerm_kubernetes_cluster.default.kube_config_raw
  sensitive = true
}
