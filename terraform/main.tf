terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
  backend "azurerm" {}

}

provider "azurerm" {
  features {}
}

# TODO: Do I also need to track my resource group for this backend?
# resource "azurerm_resource_group" "state-demo-secure" {
#   name     = resource_group_config.RESOURCE_GROUP_NAME
#   location = storage_account_config.AZ_SUBSCRIPTION_DEFAULT_LOCATION
# }