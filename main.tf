terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  cloud {
    organization = "Infra-Labs"
    workspaces {
      name = "azure-automations"
    }
  }

  required_version = ">= 1.1.0"

}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = var.azurerm_resource_group
  location = "japanwest"
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.azurerm_virtual_network
  address_space       = ["10.0.0.0/16"]
  location            = "japanwest"
  resource_group_name = var.azurerm_resource_group
}

resource "azurerm_subnet" "subnet-web" {
  name                 = var.azurerm_subnet_web
  resource_group_name  = var.azurerm_resource_group
  virtual_network_name = var.azurerm_virtual_network
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "subnet-app" {
  name                 = var.azurerm_subnet_app
  resource_group_name  = var.azurerm_resource_group
  virtual_network_name = var.azurerm_virtual_network
  address_prefixes     = ["10.0.2.0/24"]
}  

resource "azurerm_subnet" "subnet-data" {
  name                 = var.azurerm_subnet_data
  resource_group_name  = var.azurerm_resource_group
  virtual_network_name = var.azurerm_virtual_network
  address_prefixes     = ["10.0.3.0/24"]
}  

resource "azurerm_network_security_group" "nsg-web" {
  name                = var.azurerm_network_security_group_web
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "Inbound_allow"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "nsg-app" {
  name                = var.azurerm_network_security_group_app
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "Inbound_from_Sub-web"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "10.0.1.0/24"
    destination_address_prefix = "10.0.2.0/24"
  }
}

resource "azurerm_network_security_group" "nsg-data" {
  name                = var.azurerm_network_security_group_data
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "Inbound_from_Sub-data"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "10.0.2.0/24"
    destination_address_prefix = "10.0.3.0/24" 
  }
}