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
  type        = string
  default     = "sub-data"
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

variable "azurerm_public_ip_infra" {
  description = "ip-infra"
  type        = string
  default     = "ip-infra"
}

variable "azurerm_network_interface_web" {
  description = "nic-web"
  type        = string
  default     = "nic-web"
}

variable "azurerm_linux_virtual_machine_linux" {
  description = "Linux VM"
  type        = string
  default     = "linux-vm"
}

variable "azurerm_lb_infra" {
  description = "lb-infra"
  type        = string
  default     = "lb-infra"
}

variable "health_probe_lb" {
  description = "backend-health-probe"
  type        = string
  default     = "backend-health-probe"
}

variable "lb_rule_infra" {
  description = "lb-rule-infra"
  type        = string
  default     = "lb-rule-infra"
}

variable "infra_sql_database" {
  description = "infra_sql_database"
  type        = string
  default     = "infra_sql_database"
}

variable "sql_private_endpoint" {
  description = "sql_private_endpoint"
  type        = string
  default     = "sql_private_endpoint"
}

variable "lb_nat_rule" {
  description = "lb_nat_rule"
  type = string
  default = "lb_nat_rule"
}

