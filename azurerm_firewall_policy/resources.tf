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

  intrusion_detection {
    mode = var.intrusion_mode

    dynamic "signature_overrides" {
      for_each = length(var.intrusion_signature_overrides) > 0 ? var.intrusion_signature_overrides : []
      iterator = each

      content {
        id    = each.value.id
        state = each.value.state
      }
    }

    dynamic "traffic_bypass" {
      for_each = length(var.intrusion_traffic_bypasses) > 0 ? var.intrusion_traffic_bypasses : []
      iterator = each

      content {
        name                  = each.value.name
        protocol              = each.value.protocol
        description           = each.value.description
        destination_addresses = each.value.destination_addresses
        destination_ip_groups = each.value.destination_ip_groups
        destination_ports     = each.value.destination_ports
        source_addresses      = each.value.source_addresses
        source_ip_groups      = each.value.source_ip_groups
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

  tls_certificate {
    key_vault_secret_id = var.certificate.kv_secret_id
    name                = var.certificate.name
  }

  threat_intelligence_allowlist {
    fqdns        = var.threat_allowlist.fqdns
    ip_addresses = var.threat_allowlist.ip_addresses
  }

  lifecycle {
    ignore_changes = [location, sku]
  }
}

