resource "azurerm_key_vault_secret" "admin_user" {
  depends_on = [data.azurerm_key_vault.kv]

  name         = "vmss-${var.name}-admin-user"
  value        = var.admin_user
  content_type = "Windows Virtual Machine Scale Set administrator user for ${var.name}"
  key_vault_id = data.azurerm_key_vault.kv.id
  lifecycle {
    ignore_changes = [key_vault_id]
  }
}

resource "azurerm_key_vault_secret" "admin_pass" {
  depends_on = [data.azurerm_key_vault.kv]

  name         = "vmss-${var.name}-admin-pass"
  value        = var.admin_pass
  content_type = "Windows Virtual Machine Scale Set administrator password for ${var.name}"
  key_vault_id = data.azurerm_key_vault.kv.id

  lifecycle {
    ignore_changes = [key_vault_id]
  }
}

#---------------------------------------------------------------
# Generates SSH2 key Pair for Linux VM's (Dev Environment only)
#---------------------------------------------------------------
resource "tls_private_key" "rsa" {
  count     = var.generate_admin_ssh_key ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set
resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  depends_on = [
    data.azurerm_resource_group.rg,
    azurerm_key_vault_secret.admin_user,
    azurerm_key_vault_secret.admin_pass,
    tls_private_key.rsa
  ]

  name                            = var.name
  resource_group_name             = data.azurerm_resource_group.rg.name
  location                        = data.azurerm_resource_group.rg.location
  sku                             = var.sku
  instances                       = var.instances
  admin_username                  = var.admin_user
  admin_password                  = var.admin_pass
  disable_password_authentication = local.disable_password_authentication
  computer_name_prefix            = var.computer_name_prefix
  proximity_placement_group_id    = var.ppg_id
  upgrade_mode                    = var.upgrade_mode
  provision_vm_agent              = var.provision_vm_agent
  encryption_at_host_enabled      = var.disk_encryption_enabled

  # TODO: plan - (Optional) A plan block as defined below. Changing this forces a new resource to be created.

  dynamic "boot_diagnostics" {
    for_each = var.sa_blob_endpoint != null ? [1] : []
    content {
      storage_account_uri = var.sa_blob_endpoint
    }
  }

  dynamic "admin_ssh_key" {
    for_each = var.disable_password_authentication && var.public_key_file != null ? [1] : []
    content {
      username   = var.admin_user
      public_key = var.public_key_file == null ? tls_private_key.rsa[0].public_key_openssh : file(var.public_key_file)
    }
  }

  dynamic "identity" {
    for_each = var.managed_identity_type != null ? [1] : []
    content {
      type         = var.managed_identity_type
      identity_ids = local.identity_ids
    }
  }

  # az vm image list --output table
  source_image_reference {
    publisher = local.source_image[var.source_image].publisher
    offer     = local.source_image[var.source_image].offer
    sku       = local.source_image[var.source_image].sku
    version   = local.source_image[var.source_image].version
  }

  additional_capabilities {
    ultra_ssd_enabled = local.ultra_ssd_enabled
  }

  os_disk {
    caching = local.os_disk_caching
    dynamic "diff_disk_settings" {
      for_each = var.ephemeral_disk_support ? [1] : []
      content {
        option = "Local" # (Required) Specifies the Ephemeral Disk Settings for the OS Disk. At this time the only possible value is Local. Changing this forces a new resource to be created.
      }
    }
    disk_encryption_set_id    = var.os_disk.disk_encryption_set_id
    disk_size_gb              = var.os_disk.disk_size_gb
    storage_account_type      = var.os_disk.storage_account_type
    write_accelerator_enabled = local.write_accelerator_enabled
  }

  dynamic "data_disk" {
    for_each = length(var.data_disks) > 0 ? var.data_disks : []
    iterator = each

    content {
      caching                   = each.value.caching
      create_option             = each.value.create_option
      disk_size_gb              = each.value.disk_size_gb
      disk_encryption_set_id    = each.value.disk_encryption_set_id
      lun                       = each.value.lun
      storage_account_type      = each.value.storage_account_type
      write_accelerator_enabled = each.value.write_accelerator_enabled
    }
  }

  dynamic "network_interface" {
    for_each = length(var.network_interfaces) > 0 ? var.network_interfaces : []
    iterator = each

    content {
      dns_servers                   = each.value.dns_servers
      enable_accelerated_networking = each.value.enable_accelerated_networking # (Optional) Does this Network Interface support Accelerated Networking? Defaults to false
      enable_ip_forwarding          = each.value.enable_ip_forwarding          # (Optional) Does this Network Interface support IP Forwarding? Defaults to false.

      dynamic "ip_configuration" {
        for_each = length(each.value.ip_configuration) > 0 ? each.value.ip_configuration : []
        iterator = eachsub

        content {
          application_gateway_backend_address_pool_ids = eachsub.value.agw_backend_address_pool_ids
          application_security_group_ids               = eachsub.value.asg_ids
          load_balancer_backend_address_pool_ids       = eachsub.value.lb_backend_ids
          load_balancer_inbound_nat_rules_ids          = eachsub.value.lb_onbound_nat_rules_ids
          name                                         = eachsub.value.name
          primary                                      = eachsub.value.primary

          dynamic "public_ip_address" {
            for_each = var.assign_public_ip_to_each_vm_in_vmss ? [1] : []
            content {
              name                    = eachsub.value.public_ip_address.name
              domain_name_label       = eachsub.value.public_ip_address.domain_name_label
              idle_timeout_in_minutes = eachsub.value.public_ip_address.idle_timeout_in_minutes

              dynamic "ip_tag" {
                for_each = eachsub.value.public_ip_address.ip_tag.type != null ? [eachsub.value.public_ip_address.ip_tag] : []
                iterator = eachiptag
                content {
                  tag  = eachiptag.value.tag
                  type = eachiptag.value.type
                }
              }
            }
          }
          subnet_id = eachsub.value.subnet_id # subnet_id is required if version is set to IPv4
          version   = eachsub.value.version
        }
      }

      name                      = each.value.name
      network_security_group_id = each.value.network_security_group_id
      primary                   = each.value.primary
    }
  }

  dynamic "automatic_os_upgrade_policy" {
    for_each = var.upgrade_mode == "Automatic" ? [var.automatic_os_upgrade_policy] : []
    iterator = each
    content {
      disable_automatic_rollback  = each.value.disable_automatic_rollback
      enable_automatic_os_upgrade = each.value.enable_automatic_os_upgrade
    }
  }

  dynamic "rolling_upgrade_policy" {
    for_each = var.upgrade_mode != "Manual" ? [1] : []
    content {
      max_batch_instance_percent              = var.rolling_upgrade_policy.max_batch_instance_percent
      max_unhealthy_instance_percent          = var.rolling_upgrade_policy.max_unhealthy_instance_percent
      max_unhealthy_upgraded_instance_percent = var.rolling_upgrade_policy.max_unhealthy_upgraded_instance_percent
      pause_time_between_batches              = var.rolling_upgrade_policy.pause_time_between_batches
    }
  }

  dynamic "automatic_instance_repair" {
    for_each = var.health_probe_id != null ? [var.automatic_instance_repair] : []
    iterator = each
    content {
      enabled      = each.value.enabled
      grace_period = each.value.grace_period
    }
  }

  dynamic "automatic_os_upgrade_policy" {
    for_each = var.upgrade_mode == "Automatic" ? [var.automatic_os_upgrade_policy] : []
    iterator = each
    content {
      disable_automatic_rollback  = each.value.disable_automatic_rollback
      enable_automatic_os_upgrade = each.value.enable_automatic_os_upgrade
    }
  }

  automatic_instance_repair {
    enabled      = var.automatic_instance_repair.enabled
    grace_period = var.automatic_instance_repair.grace_period
  }

  lifecycle {
    ignore_changes = [
      tags["updated_date"],
      location,
      automatic_instance_repair,
      automatic_os_upgrade_policy,
      proximity_placement_group_id,
      instances,
    data_disk]
  }
}