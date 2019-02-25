provider "azurerm" {
    version = "=1.20.0"
}

terraform {
    backend "azurerm" {}
}