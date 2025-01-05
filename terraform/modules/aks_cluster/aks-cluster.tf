
resource "random_pet" "prefix" {}

resource "azurerm_resource_group" "aks_cluster_rg" {
  name     = "${random_pet.prefix.id}-rg"
  location = var.location 
}

resource "azurerm_user_assigned_identity" "aks_cluster_uai" {
  location            = var.location
  name                = "${random_pet.prefix.id}-uai"
  resource_group_name = azurerm_resource_group.aks_cluster_rg.name
}

resource "azurerm_kubernetes_cluster" "default" {
  name                = "${random_pet.prefix.id}-aks"
  location            = azurerm_resource_group.aks_cluster_rg.location
  resource_group_name = azurerm_resource_group.aks_cluster_rg.name
  dns_prefix          = "${random_pet.prefix.id}-k8s"
  kubernetes_version  = "1.26.3"

  default_node_pool {
    name            = "default"
    node_count      = 2
    vm_size         = "Standard_D2_v2"
    os_disk_size_gb = 30
  }

  identity {
    type="UserAssigned"
    principal_id= azurerm_user_assigned_identity.aks_cluster_uai.principal_id
    tenant_id = azurerm_user_assigned_identity.aks_cluster_uai.tenant_id
  }

  role_based_access_control_enabled = true

}