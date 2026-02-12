resource "azurerm_resource_group" "example" {
  lifecycle {
    create_before_destroy = true
    prevent_destroy = false
    # ignore_changes = [ tags ]
    precondition {
      condition = contains(var.allowed_locations, var.location)
      error_message = "Please enter a valid location!"
    }
  }
  name     = "${var.environment}-resources"
  location = var.allowed_locations[0]
}

resource "azurerm_storage_account" "example" {
  for_each = length(var.storage_account_name)
  name                     = each.value
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    environment = "staging"
  }
  lifecycle {
    create_before_destroy = true
    ignore_changes = [ account_replication_type ]
    replace_triggered_by = [ azurerm_resource_group.example.id ]
  }
}