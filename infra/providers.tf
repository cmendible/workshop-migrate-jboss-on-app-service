terraform {
  required_version = "> 0.14"
  required_providers {
    azurerm = {
      version = "= 3.90.0"
    }
    random = {
      version = ">= 3.6.0"
    }
  }
}

provider "azurerm" {
  skip_provider_registration = true
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}