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

resource "azurerm_public_ip" "ipinfra" {
  name                = var.azurerm_public_ip_infra
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  allocation_method = "Static"
  sku               = "Standard"

}

resource "azurerm_network_interface" "nic-web" {
  name                = var.azurerm_network_interface_web
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet-web.id
    private_ip_address_allocation = "Dynamic"
  }

}

resource "azurerm_network_interface_security_group_association" "nic-web-nsg" {
  network_interface_id      = azurerm_network_interface.nic-web.id
  network_security_group_id = azurerm_network_security_group.nsg-web.id
}


resource "azurerm_linux_virtual_machine" "linux-vm" {
  name                = var.azurerm_linux_virtual_machine_linux
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_D2s_v3"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.nic-web.id,
  ]

  admin_password                  = "Password__123"
  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "24.04.202404230"
  }
}

resource "azurerm_lb" "lb_infra" {
  name                = var.azurerm_lb_infra
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "LoadBalancerFrontEnd"
    public_ip_address_id = azurerm_public_ip.ipinfra.id
  }

}

resource "azurerm_lb_backend_address_pool" "backend_pool" {
  name            = "backend-pool"
  loadbalancer_id = azurerm_lb.lb_infra.id
}

resource "azurerm_lb_probe" "health_probe_infra" {
  name            = var.health_probe_lb
  loadbalancer_id = azurerm_lb.lb_infra.id
  protocol        = "Tcp"
  port            = 80
}

resource "azurerm_lb_rule" "lb_rule" {
  name                           = var.lb_rule_infra
  loadbalancer_id                = azurerm_lb.lb_infra.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "LoadBalancerFrontEnd"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.backend_pool.id]
  probe_id                       = azurerm_lb_probe.health_probe_infra.id
}

resource "azurerm_network_interface_backend_address_pool_association" "vm_pool" {
  network_interface_id    = azurerm_network_interface.nic-web.id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.backend_pool.id
}

resource "azurerm_mssql_server" "infra-sql_server" {
  name                         = "infra-sql-server-v2"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = "japaneast"
  version                      = "12.0"
  administrator_login          = "dbmaster"
  administrator_login_password = "Password__123"
}

resource "azurerm_mssql_database" "infra_sql_database" {
  name      = var.infra_sql_database
  server_id = azurerm_mssql_server.infra-sql_server.id
  sku_name  = "Basic"
}

resource "azurerm_private_dns_zone" "sql_dns" {
  name                = "private.sql.database.azure.com"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "sql_dns_link" {
  name                  = "sql-dns-link"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.sql_dns.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}

resource "azurerm_private_endpoint" "sql_private_endpoint" {
  name                = var.sql_private_endpoint
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  subnet_id           = azurerm_subnet.subnet-data.id

  private_service_connection {
    name                           = "sql-private-service-connection"
    private_connection_resource_id = azurerm_mssql_server.infra-sql_server.id
    is_manual_connection           = false
    subresource_names              = ["sqlServer"]
  }

  private_dns_zone_group {
    name                 = "sql_dns_aone_group"
    private_dns_zone_ids = [azurerm_private_dns_zone.sql_dns.id]
  }
}