variable "azurerm_resource_group" {
  description = "Infralabs-Automations"
  type        = string
  default     = "Infralabs-Automations"
}

variable "azurerm_virtual_network" {
  description = "Infralabs-vnet"
  type        = string
  default     = "Infralabs-vnet"
}

variable "azurerm_subnet_web" {
  description = "sub-web"
  type        = string
  default     = "sub-web"
}

variable "azurerm_subnet_app" {
  description = "sub-app"
  type        = string
  default     = "sub-app"
}

variable "azurerm_subnet_data" {
  description = "sub-data"
  type = string
  default = "sub-data"
}


variable "azurerm_network_security_group_web" {
  description = "NSG-Web"
  type        = string
  default     = "NSG-Web"
}

variable "azurerm_network_security_group_app" {
  description = "NSG-app"
  type        = string
  default     = "NSG-app"
}

variable "azurerm_network_security_group_data" {
  description = "NSG-data"
  type        = string
  default     = "NSG-data"
}


