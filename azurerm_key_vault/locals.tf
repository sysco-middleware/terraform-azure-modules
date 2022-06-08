locals {
  interpreter          = ["PowerShell", "-Command"]
  is_selected_networks = var.network_acls.default_action == "Deny"
  key_opts = [
    "decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"
  ]
  is_premium = var.sku_name == "premium" ? true : false

  permissions = {
    Owner = {
      key_permissions         = ["Create", "Get", "Purge", "Recover", "List", "Delete", "Update", "Backup", "Restore"]
      secret_permissions      = ["Get", "List", "Set", "Delete", "Purge", "Recover", "Backup", "Restore"]
      certificate_permissions = ["Backup", "Create", "Delete", "DeleteIssuers", "Get", "GetIssuers", "Import", "List", "ListIssuers", "ManageContacts", "ManageIssuers", "Purge", "Recover", "Restore", "SetIssuers", "Update"]
      storage_permissions     = ["Backup", "Delete", "Get", "List", "Restore", "Update", "Recover", "RegenerateKey"]
    }
    Contributor = {
      key_permissions         = ["Create", "Get", "Purge", "List", "Delete", "Update"]
      secret_permissions      = ["Get", "List", "Set", "Delete", "Purge"]
      certificate_permissions = ["Backup", "Create", "Delete", "Get", "GetIssuers", "Import", "List", "ListIssuers", "Purge", "Update"]
      storage_permissions     = ["Backup", "Delete", "Get", "List", "Restore", "Update", "Recover", "RegenerateKey"]
    }
    Reader = {
      key_permissions         = ["Get", "List"]
      secret_permissions      = ["Get", "List"]
      certificate_permissions = ["Get", "GetIssuers", "List", "ListIssuers"]
      storage_permissions     = ["Get", "List"]
    }
  }

  access_policies_rbac = [
    for item in var.access_policies_rbac :
    {
      object_id               = item.object_id
      key_permissions         = local.permissions[item.key_role].key_permissions
      secret_permissions      = local.permissions[item.secret_role].secret_permissions
      certificate_permissions = local.permissions[item.certificate_role].certificate_permissions
      storage_permissions     = local.permissions[item.storage_role].storage_permissions
    }
  ]

  access_policies = length(local.access_policies_rbac) > 0 ? local.access_policies_rbac : var.access_policies
}
