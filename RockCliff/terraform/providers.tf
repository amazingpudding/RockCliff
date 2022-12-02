terraform {
  required_version = ">=0.12"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id   = "808499be-9a45-4135-9db5-997fbbe5626f"
  tenant_id         = "5ed94e26-7014-467d-a249-b97cc8fbb45c"
  client_id         = "2f2e20c5-3e9a-41bc-a0bc-1811da5e74c7"
  client_certificate_path = var.client_certificate_path
  client_certificate_password = var.client_certificate_password
  
}

