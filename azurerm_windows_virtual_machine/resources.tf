resource "azurerm_key_vault_secret" "admin_user" {
  depends_on = [data.azurerm_key_vault.kv]

  name         = "vm-${var.name}-admin-user"
  value        = var.admin_user
  content_type = "Windows Virtual Machine administrator user for ${var.name}"
  key_vault_id = data.azurerm_key_vault.kv.id
  lifecycle {
    ignore_changes = [key_vault_id]
  }
}

resource "azurerm_key_vault_secret" "admin_pass" {
  depends_on = [data.azurerm_key_vault.kv]

  name         = "vm-${var.name}-admin-pass"
  value        = var.admin_pass
  content_type = "Windows Virtual Machine administrator password for ${var.name}"
  key_vault_id = data.azurerm_key_vault.kv.id

  lifecycle {
    ignore_changes = [key_vault_id]
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_virtual_machine
resource "azurerm_windows_virtual_machine" "wvm" {
  depends_on = [
    data.azurerm_resource_group.rg,
    azurerm_key_vault_secret.admin_user,
    azurerm_key_vault_secret.admin_pass
  ]

  name                         = var.name
  resource_group_name          = data.azurerm_resource_group.rg.name
  location                     = data.azurerm_resource_group.rg.location
  computer_name                = var.computer_name
  size                         = var.size
  admin_username               = var.admin_user
  admin_password               = var.admin_pass
  network_interface_ids        = var.nic_ids
  availability_set_id          = var.vmss_id == null ? null : var.as_id
  enable_automatic_updates     = var.enable_automatic_updates
  patch_mode                   = var.patch_mode
  priority                     = var.priority
  proximity_placement_group_id = var.ppg_id
  timezone                     = var.timezone
  virtual_machine_scale_set_id = var.vmss_id
  license_type                 = var.license_type
  encryption_at_host_enabled   = var.disk_encryption_enabled
  provision_vm_agent           = var.provision_vm_agent
  source_image_id              = var.source_image_id

  # TODO: dedicated_host_id 
  # TODO: dedicated_host_group_id 
  # TODO: eviction_policy 

  dynamic "boot_diagnostics" {
    for_each = var.sa_blob_endpoint != null ? [1] : []
    content {
      storage_account_uri = var.sa_blob_endpoint
    }
  }

  os_disk {
    name                      = local.os_disk_name
    storage_account_type      = var.os_disk.storage_account_type
    caching                   = local.os_disk_caching
    disk_encryption_set_id    = var.os_disk.disk_encryption_set_id
    write_accelerator_enabled = local.write_accelerator_enabled

    dynamic "diff_disk_settings" {
      for_each = var.ephemeral_disk_support ? [1] : []
      content {
        option = "Local" # (Required) Specifies the Ephemeral Disk Settings for the OS Disk. At this time the only possible value is Local. Changing this forces a new resource to be created.
      }
    }
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = local.source_image[var.source_image].sku
    version   = local.source_image[var.source_image].version
  }

  dynamic "identity" {
    for_each = var.managed_identity_type != null ? [1] : []
    content {
      type         = var.managed_identity_type
      identity_ids = local.identity_ids
    }
  }

  dynamic "additional_unattend_content" {
    for_each = length(var.unattend_content) > 0 ? var.unattend_content : []
    iterator = each

    content {
      content = each.value.content
      setting = each.value.setting
    }
  }

  secret {
    key_vault_id = data.azurerm_key_vault.kv.id
    certificate {
      #  (Required) The ID of the Key Vault Secret. Stored secret is the Base64 encoding of a JSON Object that which is encoded in UTF-8 of which the contents need to be:
      url   = data.azurerm_key_vault_certificate.kv_cert.secret_id
      store = "My" # (Required, on windows machines) Specifies the certificate store on the Virtual Machine where the certificate should be added to, such as My
    }
  }

  winrm_listener {
    protocol        = "Https"
    certificate_url = data.azurerm_key_vault_certificate.kv_cert.secret_id
  }

  lifecycle {
    ignore_changes = [tags["updated_date"], location, enable_automatic_updates, winrm_listener, os_disk["name"]]
  }
}

resource "azurerm_management_lock" "vm_lock" {
  depends_on = [azurerm_windows_virtual_machine.wvm]
  count      = var.lock_resource ? 1 : 0

  name       = "CanNotDelete"
  scope      = azurerm_windows_virtual_machine.wvm.id
  lock_level = "CanNotDelete"
  notes      = "Terraform: This prevents accidental deletion on this resource."

  lifecycle {
    ignore_changes = [name, notes]
  }
}

