# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/firewall_policy

resource "azurerm_firewall_policy" "policy" {
  depends_on = [data.azurerm_resource_group.rg]

  name                = var.name
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location

  dns {
    network_rule_fqdn_enabled = false
    servers                   = var.dns_servers
  }

  intrusion_detection {
    mode = "Alert" # Off | Alert | Deny
    signature_overrides {
      id    = 777777777777 #  (Optional) 12-digit number (id) which identifies your signature.
      state = "Off"        #  (Optional) state can be any of "Off", "Alert" or "Deny".
    }

    traffic_bypass {
      name                  = "${var.name}-bypass_traffic"
      protocol              = "ANY"    #  (Required) The protocols any of "ANY", "TCP", "ICMP", "UDP" that shall be bypassed by intrusion detection.
      description           = "Bypass" #  (Optional) The description for this bypass traffic setting.
      destination_addresses = ["TODO"] # (Optional) Specifies a list of destination IP addresses that shall be bypassed by intrusion detection.
      destination_ip_groups = ["TODO"] # (Optional) Specifies a list of destination IP groups that shall be bypassed by intrusion detection
      destination_ports     = ["TODO"] # (Optional) Specifies a list of destination IP ports that shall be bypassed by intrusion detection.
      source_addresses      = ["TODO"] # (Optional) Specifies a list of source addresses that shall be bypassed by intrusion detection.
      source_ip_groups      = ["TODO"] # (Optional) Specifies a list of source ip groups that shall be bypassed by intrusion detection.
    }
  }

  private_ip_ranges = ["value"]
  sku               = var.sku_tier
  
  tls_certificate {
    key_vault_secret_id = var.kv_secret_id
    name                = var.kv_secret_name
  }
  
  threat_intelligence_allowlist {
    fqdns        = [] # (Optional) A list of FQDNs that will be skipped for threat detection.
    ip_addresses = [] #(Optional) A list of IP addresses or IP address ranges that will be skipped for threat detection.
  }
  threat_intelligence_mode = local.threat_intel_mode
}

