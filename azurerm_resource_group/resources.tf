resource "null_resource" "delete_lock" {
  count = var.delete_all_locks ? 1 : 0
  provisioner "local-exec" {
    when    = create
    command = <<EOF
      az lock delete --name DeleteLock --resource-group ${var.name} --only-show-errors
    EOF
    #interpreter = ["PowerShell", "-Command"]
    working_dir = path.module
    on_failure  = continue
  }
}
resource "azurerm_resource_group" "rg" {
  name     = var.name
  location = var.location
  tags     = var.tags

  provisioner "local-exec" {
    command    = "echo Creating Resource group ${self.name}"
    on_failure = continue
  }

  lifecycle {
    ignore_changes = [tags["updated_date"], location]
  }
}

resource "azurerm_management_lock" "rg_lock" {
  depends_on = [azurerm_resource_group.rg]
  count      = var.lock_resource ? 1 : 0

  name       = "CanNotDelete"
  scope      = azurerm_resource_group.rg.id
  lock_level = "CanNotDelete"
  notes      = "Terraform: This prevents accidental deletion of this resource and sub resources."

  lifecycle {
    ignore_changes = [name, notes]
  }
}

///////////////////////////////////////////////////////////////////////
//////////// RBAC

resource "azurerm_role_assignment" "role_rbac" {
  depends_on = [azurerm_resource_group.rg]
  count      = length(var.rbac_roles)

  scope                = azurerm_resource_group.rg.id
  role_definition_name = var.rbac_roles[count.index].role_definition_name
  principal_id         = var.rbac_roles[count.index].principal_id
}
