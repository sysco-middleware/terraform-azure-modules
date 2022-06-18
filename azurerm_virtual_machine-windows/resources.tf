resource "azurerm_key_vault_secret" "admin_user" {
  depends_on = [data.azurerm_key_vault.kv]

  name         = "vm-${var.name}-win-admin-user"
  value        = var.admin_user
  content_type = "Azure Virtual Machine administrator user"
  key_vault_id = data.azurerm_key_vault.kv.id
  lifecycle {
    ignore_changes = [key_vault_id]
  }
}

resource "azurerm_key_vault_secret" "admin_pass" {
  depends_on = [data.azurerm_key_vault.kv]

  name         = "vm-${var.name}-win-admin-pass"
  value        = var.admin_pass
  content_type = "Azure Virtual Machine administrator password"
  key_vault_id = data.azurerm_key_vault.kv.id

  lifecycle {
    ignore_changes = [key_vault_id]
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine
resource "azurerm_virtual_machine" "vm" {
  depends_on = [
    data.azurerm_resource_group.rg,
    azurerm_key_vault_secret.admin_user,
    azurerm_key_vault_secret.admin_pass
  ]

  name                             = var.name
  resource_group_name              = data.azurerm_resource_group.rg.name
  location                         = data.azurerm_resource_group.rg.location
  network_interface_ids            = [data.azurerm_network_interface.nic.id]
  vm_size                          = var.vm_size
  delete_os_disk_on_termination    = true # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_data_disks_on_termination = true # Uncomment this line to delete the data disks automatically when deleting the VM
  tags                             = var.tags


  identity {
    type = "SystemAssigned"
  }
  storage_image_reference {
    publisher = local.publisher
    offer     = local.offer
    sku       = local.sku
    version   = "latest"
  }
  storage_os_disk {
    name              = var.disk_name
    caching           = "ReadWrite"
    create_option     = "FromImage" # Empty
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = var.computer_name
    admin_username = var.admin_user
    admin_password = var.admin_pass
  }
  os_profile_windows_config {
    enable_automatic_upgrades = false # (Optional) Are automatic updates enabled on this Virtual Machine? Defaults to false
    timezone                  = var.timezone
    winrm {
      protocol        = "HTTPS"
      certificate_url = data.azurerm_key_vault_certificate.kv_cert.secret_id # (Optional) The ID of the Key Vault Secret which contains the encrypted Certificate which should be installed on the Virtual Machine. This certificate must also be specified in the vault_certificates block within the os_profile_secrets block.
    }
  }
  os_profile_secrets {
    source_vault_id = data.azurerm_key_vault.kv.id
    vault_certificates {
      #  (Required) The ID of the Key Vault Secret. Stored secret is the Base64 encoding of a JSON Object that which is encoded in UTF-8 of which the contents need to be:
      certificate_url   = data.azurerm_key_vault_certificate.kv_cert.secret_id
      certificate_store = "My" # (Required, on windows machines) Specifies the certificate store on the Virtual Machine where the certificate should be added to, such as My
    }
  }
  lifecycle {
    ignore_changes = [tags["updated_date"], location]
  }
}

resource "azurerm_management_lock" "vm_lock" {
  depends_on = [azurerm_virtual_machine.vm]
  count      = var.lock_resource ? 1 : 0

  name       = "CanNotDelete"
  scope      = azurerm_virtual_machine.vm.id
  lock_level = "CanNotDelete"
  notes      = "Terraform: This prevents accidental deletion on this resource."

  lifecycle {
    ignore_changes = [name, notes]
  }
}

