resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "West Europe"
}

resource "azurerm_network_security_group" "example" {
  name                = "acceptanceTestSecurityGroup1"
  #conditional expression
#   name                = var.environment == "dev" ? "dev-nsg" : "stage-nsg"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
#dynamic expression
  dynamic "security_rule" {
    for_each = local.nsg_rules
    content{
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

  tags = {
    environment = "Production"
  }
}

output "env" {
  value = var.environment
}

#splat expression
# output "demo" {
#   value = [ for count in local.nsg_rules : count.description ]
# }
# output "splat" {
#   value = var.account_names[1]
# }