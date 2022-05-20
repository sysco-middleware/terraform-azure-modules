# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/firewall_policy
resource "azurerm_firewall_policy" "policy" {
  depends_on = [data.azurerm_resource_group.rg]

  name                     = var.name
  resource_group_name      = data.azurerm_resource_group.rg.name
  location                 = data.azurerm_resource_group.rg.location
  private_ip_ranges        = local.private_ip_ranges
  sku                      = var.sku_tier
  threat_intelligence_mode = var.threat_mode
  base_policy_id           = var.base_policy_id
  tags                     = var.tags

  dns {
    proxy_enabled = var.dns.proxy_enabled
    servers       = var.dns.servers
  }

  dynamic "identity" {
    for_each = length(var.managed_identity_ids) > 0 ? [1] : []
    content {
      type         = var.managed_identity_type
      identity_ids = var.managed_identity_ids
    }
  }

  # Only when sku is Premium
  dynamic "intrusion_detection" {
    for_each = local.is_premium ? [1] : []

    content {
      mode = var.intrusion_mode

      dynamic "signature_overrides" {
        for_each = length(var.intrusion_signature_overrides) > 0 ? var.intrusion_signature_overrides : []
        iterator = eachsub

        content {
          id    = eachsub.value.id
          state = eachsub.value.state
        }
      }

      dynamic "traffic_bypass" {
        for_each = length(var.intrusion_traffic_bypasses) > 0 ? var.intrusion_traffic_bypasses : []
        iterator = eachsub

        content {
          name                  = eachsub.value.name
          protocol              = eachsub.value.protocol
          description           = eachsub.value.description
          destination_addresses = eachsub.value.destination_addresses
          destination_ip_groups = eachsub.value.destination_ip_groups
          destination_ports     = eachsub.value.destination_ports
          source_addresses      = eachsub.value.source_addresses
          source_ip_groups      = eachsub.value.source_ip_groups
        }
      }
    }
  }

  insights {
    enabled                            = var.logs.enabled
    default_log_analytics_workspace_id = var.logs.law_id
    retention_in_days                  = var.logs.retention

    dynamic "log_analytics_workspace" {
      for_each = length(var.logs.laws) > 0 ? var.logs.laws : []
      iterator = each

      content {
        id                = each.value.id
        firewall_location = each.value.firewall_location
      }
    }
  }

  # Only when sku is Premium
  dynamic "tls_certificate" {
    for_each = local.is_premium && var.certificate.enabled ? [1] : []

    content {
      key_vault_secret_id = var.certificate.kv_secret_id
      name                = var.certificate.name
    }
  }

  threat_intelligence_allowlist {
    fqdns        = var.threat_allowlist.fqdns
    ip_addresses = var.threat_allowlist.ip_addresses
  }

  provisioner "local-exec" {
    command    = "echo Provisioned ${self.name}"
    on_failure = continue
  }

  lifecycle {
    ignore_changes = [location]
  }
}

