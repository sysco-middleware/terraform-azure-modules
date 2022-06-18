
resource "null_resource" "kv_recover" {
  depends_on = [data.azurerm_resource_group.rg]
  count      = var.recover_keyvault ? 1 : 0

  triggers = {
    // always execute
    uuid_trigger = "${uuid()}"
  }
  provisioner "local-exec" {
    when        = create
    command     = <<EOF
      "az keyvault recover --name ${var.name} --resource-group ${var.rg_name}"
    EOF
    interpreter = local.interpreter
    working_dir = path.module
    on_failure  = continue
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault
resource "azurerm_key_vault" "kv" {
  depends_on = [null_resource.kv_recover]

  name                            = var.name
  resource_group_name             = data.azurerm_resource_group.rg.name
  location                        = data.azurerm_resource_group.rg.location
  enabled_for_disk_encryption     = true
  tenant_id                       = var.tenant_id
  soft_delete_retention_days      = var.soft_delete_retention_days
  purge_protection_enabled        = var.purge_protection_enabled
  enabled_for_deployment          = true
  enabled_for_template_deployment = true
  enable_rbac_authorization       = var.enable_rbac_authorization
  sku_name                        = var.sku_name
  tags                            = var.tags

  network_acls {
    default_action             = var.network_acls.default_action
    bypass                     = var.network_acls.bypass
    ip_rules                   = var.network_acls.ip_rules
    virtual_network_subnet_ids = var.network_acls.virtual_network_subnet_ids
  }

  provisioner "local-exec" {
    command    = "echo Provisioned ${self.name}"
    on_failure = continue
  }

  provisioner "local-exec" {
    when    = destroy
    command = "echo 'Destroyed ${self.name}'"
  }

  lifecycle {
    ignore_changes = [tags, location, soft_delete_retention_days] # Must have this or else the resource will be replaced
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault
resource "azurerm_key_vault_access_policy" "policy" {
  depends_on = [azurerm_key_vault.kv]
  count      = var.enable_rbac_authorization ? 0 : length(local.access_policies)

  key_vault_id            = azurerm_key_vault.kv.id
  tenant_id               = var.tenant_id
  object_id               = local.access_policies[count.index].object_id
  key_permissions         = local.access_policies[count.index].key_permissions
  secret_permissions      = local.access_policies[count.index].secret_permissions
  storage_permissions     = local.is_premium ? local.access_policies[count.index].storage_permissions : []
  certificate_permissions = local.access_policies[count.index].certificate_permissions

  lifecycle {
    ignore_changes = [key_vault_id, object_id] # Must have this or else the resource will be replaced
  }
}

resource "azurerm_key_vault_secret" "secret" {
  depends_on = [azurerm_key_vault_access_policy.policy, azurerm_role_assignment.role]
  count      = length(var.secrets)

  key_vault_id = azurerm_key_vault.kv.id
  name         = var.secrets[count.index].name
  value        = var.secrets[count.index].value
  content_type = var.secrets[count.index].content_type
}

resource "azurerm_key_vault_key" "key" {
  depends_on = [azurerm_key_vault_access_policy.policy, azurerm_role_assignment.role]
  count      = length(var.keys)

  key_vault_id = azurerm_key_vault.kv.id
  name         = var.keys[count.index].name
  key_type     = var.keys[count.index].key_type
  key_size     = var.keys[count.index].key_size
  key_opts     = length(var.keys[count.index].key_opts) > 0 ? var.keys[count.index].key_opts : local.key_opts

  lifecycle {
    ignore_changes = [name]
  }
}

resource "azurerm_key_vault_certificate" "cert" {
  depends_on = [azurerm_key_vault_access_policy.policy, azurerm_role_assignment.role]
  count      = length(var.certificates_pfx)

  name         = var.certificates_pfx[count.index].name
  key_vault_id = azurerm_key_vault.kv.id

  certificate {
    contents = filebase64(var.certificates_pfx[count.index].pfx_file)
    password = var.certificates_pfx[count.index].password
  }
}

resource "azurerm_role_assignment" "role" {
  depends_on = [azurerm_key_vault.kv]
  count      = var.enable_rbac_authorization ? length(var.rbac_roles) : 0

  scope                = azurerm_key_vault.kv.id
  role_definition_name = var.rbac_roles[count.index].role_definition_name
  principal_id         = var.rbac_roles[count.index].principal_id
}

resource "azurerm_management_lock" "kv_lock" {
  depends_on = [azurerm_key_vault.kv]
  count      = var.lock_resource ? 1 : 0

  name       = "CanNotDelete"
  scope      = azurerm_key_vault.kv.id
  lock_level = "CanNotDelete"
  notes      = "Terraform: This prevents accidental deletion of this resource."

  lifecycle {
    ignore_changes = [name, notes]
  }
}
