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

module "aks_cluster" {
    source = "./modules/aks_cluster"
    location = var.az_subscription_default_location
}
