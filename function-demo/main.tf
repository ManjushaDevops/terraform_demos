locals {
  formatted_name = lower(replace(var.project_name, " ", "-"))
  merge_tags = merge(var.default_tags, var.environment_tags)
  storage_formatted = replace(replace(lower(substr(var.storage_account_name,0,23))," ", ""),"!","")
  formatted_ports = split((var.allowed_ports), ",")
  nsg_rules = join[for port in local.formatted_ports : "port-${port}" ]
  vm_size = lookup(var.vm_sizes,var.environment,lower("dev"))
  #use case 9
  user_location = ["eastus", "westus","eastus"]
  default_location = ["centralus"]
  unique_location = toset(concat(local.user_location,local.default_location))
  #use case 10
  monthly_costs = [-50, 100, 75, 200]
  positive_cost = [for cost in local.monthly_costs :
  abs(cost)]
  max_cost = max(local.positive_cost...)

}
resource azurerm_resource_group rg {
name = "${local.formatted_name}-rg"
location = "westus2" 
tags = local.merge_tags
}
resource "azurerm_storage_account" "example" {
   
  name = local.storage_formatted
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}
resource "azurerm_network_security_group" "example" {
  name                = "acceptanceTestSecurityGroup1"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
output "rgname" {
  value = azurerm_resource_group.rg.name
}
output "storagename" {
  value = azurerm_storage_account.example.name
}
output "vm_size" {
  value = local.vm_size
}
output "backup" {
  value = var.backup_name
}

output "credential" {
    value = var.credential
    sensitive = true
  
}
output "unique_location" {
  value = local.unique_location
}
output "max_cost"{
    value = local.max_cost
}

output "positive" {
    value = local.positive_cost
  
}