resource "azurerm_user_assigned_identity" "uai" {
  depends_on = [data.azurerm_resource_group.rg]
  count      = local.uai_install ? 1 : 0

  name                = local.uai_name
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location

  lifecycle {
    ignore_changes = [tags, location]
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_gateway
# https://docs.microsoft.com/en-us/azure/developer/terraform/deploy-application-gateway-v2?toc=%2Fazure%2Fapplication-gateway%2Ftoc.json&bc=%2Fazure%2Fapplication-gateway%2Fbreadcrumb%2Ftoc.json
resource "azurerm_application_gateway" "agw" {
  depends_on = [azurerm_user_assigned_identity.uai]

  name                = var.name
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  firewall_policy_id  = var.fw_policy_id
  fips_enabled        = var.fips_enabled
  enable_http2        = var.http2_enabled
  zones               = var.zones
  tags                = var.tags

  sku {
    name     = var.sku
    tier     = var.tier
    capacity = var.autoscale.enabled ? null : var.capacity
  }

  # Identity for the selected SKU tier Standard. Supported SKU tiers are Standard_v2,WAF_v2
  dynamic "identity" {
    for_each = local.is_sku_tier_v2 ? [1] : []

    content {
      type         = "UserAssigned" # (Optional) The Managed Service Identity Type of this Application Gateway. The only possible value is UserAssigned. Defaults to UserAssigned
      identity_ids = local.uai_install ? concat([azurerm_user_assigned_identity.uai[0].id], var.managed_identity_ids) : var.managed_identity_ids
    }
  }

  dynamic "autoscale_configuration" {
    for_each = var.autoscale.enabled ? [var.autoscale] : []
    iterator = each

    content {
      max_capacity = each.value.max_capacity
      min_capacity = each.value.min_capacity
    }
  }

  dynamic "gateway_ip_configuration" {
    for_each = length(var.gateway_ips) > 0 ? var.gateway_ips : []
    iterator = each

    content {
      name      = each.value.name
      subnet_id = each.value.snet_id
    }
  }

  dynamic "frontend_port" {
    for_each = length(var.frontend_ports) > 0 ? var.frontend_ports : []
    iterator = each

    content {
      name = each.value.name
      port = each.value.port
    }
  }

  dynamic "private_link_configuration" {
    for_each = length(var.private_links) > 0 ? var.private_links : []
    iterator = each

    content {
      name = each.value.name
      dynamic "ip_configuration" {
        for_each = length(each.value.ip_configurations) > 0 ? each.value.ip_configurations : []
        iterator = eachsub

        content {
          name                          = eachsub.value.name
          subnet_id                     = eachsub.value.snet_id
          private_ip_address_allocation = eachsub.value.pipa_allocation
          primary                       = eachsub.value.primary
          private_ip_address            = eachsub.value.pipa
        }
      }
    }
  }

  dynamic "frontend_ip_configuration" {
    for_each = length(var.frontend_ips) > 0 ? var.frontend_ips : []
    iterator = each

    content {
      name                            = each.value.name
      subnet_id                       = each.value.snet_id
      private_ip_address              = each.value.private_ip
      public_ip_address_id            = each.value.pipa_id
      private_ip_address_allocation   = each.value.pripa_allocation
      private_link_configuration_name = each.value.private_link_cn
    }
  }

  dynamic "backend_address_pool" {
    for_each = length(var.backend_address_pools) > 0 ? var.backend_address_pools : []
    iterator = each

    content {
      name         = each.value.name
      ip_addresses = each.value.ip_addresses
      fqdns        = each.value.fqdns
    }
  }

  dynamic "backend_http_settings" {
    for_each = length(var.backend_http_settings) > 0 ? var.backend_http_settings : []
    iterator = each

    content {
      name                                = each.value.name
      cookie_based_affinity               = each.value.cookie_based_affinity # "Disabled"
      affinity_cookie_name                = each.value.affinity_cookie_name  # "ApplicationGatewayAffinity"
      port                                = each.value.port                  # 443
      protocol                            = each.value.protocol              # "Https"
      request_timeout                     = each.value.request_timeout       # 10
      path                                = each.value.path                  #"/path"
      probe_name                          = each.value.probe_name            # "probetest01abc"
      host_name                           = each.value.phnfba ? null : each.value.host_name
      pick_host_name_from_backend_address = each.value.phnfba
      trusted_root_certificate_names      = each.value.trcns

      dynamic "authentication_certificate" {
        for_each = each.value.auth_certificates != null ? each.value.auth_certificates : []
        iterator = eachsub

        content {
          name = eachsub.value.name
        }
      }

      dynamic "connection_draining" {
        for_each = each.value.connection_draining == null ? [] : [1]

        content {
          enabled           = each.value.connection_draining.enabled
          drain_timeout_sec = each.value.connection_draining.timeout_sec
        }
      }
    }
  }

  dynamic "http_listener" {
    for_each = length(var.http_listeners) > 0 ? var.http_listeners : []
    iterator = each

    content {
      name                           = each.value.name
      frontend_ip_configuration_name = each.value.fe_ip_conf_name
      frontend_port_name             = each.value.fe_port_name
      protocol                       = each.value.protocol
      host_name                      = each.value.host_name
      host_names                     = each.value.host_name == null ? each.value.host_names : null
      require_sni                    = each.value.require_sni
      ssl_certificate_name           = each.value.ssl_cert_name
      ssl_profile_name               = each.value.ssl_profile_name
      firewall_policy_id             = each.value.fw_policy_id
      # require_sni - (Optional) Should Server Name Indication be Required? Defaults to false.

      dynamic "custom_error_configuration" {
        for_each = length(each.value.custom_errors) > 0 ? each.value.custom_errors : []
        iterator = eachsub

        content {
          status_code           = eachsub.value.status_code
          custom_error_page_url = eachsub.value.page_url
        }
      }
    }
  }

  dynamic "rewrite_rule_set" {
    for_each = length(var.rewrite_rule_sets) > 0 ? var.rewrite_rule_sets : []
    iterator = each

    content {
      name = each.value.name

      dynamic "rewrite_rule" {
        for_each = length(each.value.rewrite_rules) > 0 ? each.value.rewrite_rules : []
        iterator = eachsub

        content {
          name          = eachsub.value.name
          rule_sequence = eachsub.value.sequence

          dynamic "condition" {
            for_each = length(eachsub.value.conditions) > 0 ? eachsub.value.conditions : []
            iterator = eachsubsub

            content {
              variable    = eachsubsub.value.variable
              pattern     = eachsubsub.value.pattern
              ignore_case = eachsubsub.value.ignore_case
              negate      = eachsubsub.value.negate
            }
          }

          dynamic "request_header_configuration" {
            for_each = length(eachsub.value.request_headers) > 0 ? eachsub.value.request_headers : []
            iterator = eachsubsub

            content {
              header_name  = eachsubsub.value.name
              header_value = eachsubsub.value.value
            }
          }

          dynamic "response_header_configuration" {
            for_each = length(eachsub.value.response_headers) > 0 ? eachsub.value.response_headers : []
            iterator = eachsubsub

            content {
              header_name  = eachsubsub.value.name
              header_value = eachsubsub.value.value
            }
          }

          url {
            path         = eachsub.value.url.path
            query_string = eachsub.value.url.query_string
            reroute      = eachsub.value.url.reroute
          }
        }
      }
    }
  }

  dynamic "url_path_map" {
    for_each = length(var.url_path_maps) > 0 ? var.url_path_maps : []
    iterator = each

    content {
      name                                = each.value.name
      default_backend_address_pool_name   = each.value.def_redirect_conf != null ? null : each.value.def_be_address_pool
      default_backend_http_settings_name  = each.value.def_redirect_conf != null ? null : each.value.def_be_setting
      default_redirect_configuration_name = each.value.def_redirect_conf
      default_rewrite_rule_set_name       = local.is_sku_tier_v2 ? each.value.def_rewrite_rule_set : null

      dynamic "path_rule" {
        for_each = length(each.value.path_rules) > 0 ? each.value.path_rules : []
        iterator = eachsub

        content {
          name                        = eachsub.value.name
          paths                       = eachsub.value.paths
          backend_address_pool_name   = eachsub.value.redirect_conf != null ? null : eachsub.value.be_address_pool
          backend_http_settings_name  = eachsub.value.redirect_conf != null ? null : eachsub.value.be_setting
          redirect_configuration_name = eachsub.value.redirect_conf
          rewrite_rule_set_name       = local.is_sku_tier_v2 ? eachsub.value.rewrite_rule_set : null
          firewall_policy_id          = eachsub.value.fw_policy_id
        }
      }
    }
  }

  dynamic "request_routing_rule" {
    for_each = length(var.request_routing_rules) > 0 ? var.request_routing_rules : []
    iterator = each

    content {
      name                        = each.value.name
      rule_type                   = each.value.rule_type
      http_listener_name          = each.value.listener_name
      backend_address_pool_name   = each.value.redirect_conf != null ? each.value.be_address_pool : null
      backend_http_settings_name  = each.value.redirect_conf != null ? each.value.be_setting : null
      redirect_configuration_name = each.value.redirect_conf
      rewrite_rule_set_name       = local.is_sku_tier_v2 && each.value.rule_type == "Basic" ? each.value.rewrite_rule_set : null
      url_path_map_name           = each.value.rule_type == "Basic" ? null : each.value.url_path_map_name
      priority                    = each.value.priority
    }
  }

  waf_configuration {
    enabled                  = local.is_waf ? true : false
    firewall_mode            = var.waf.firewall_mode
    rule_set_version         = var.waf.rule_set_version
    rule_set_type            = "OWASP" # (Required) The Type of the Rule Set used for this Web Application Firewall. Currently, only OWASP is supported.
    request_body_check       = var.waf.request_body_check
    max_request_body_size_kb = 128 # (Optional) The Maximum Request Body Size in KB. Accepted values are in the range 1KB to 128KB. Defaults to 128KB.

    dynamic "disabled_rule_group" {
      for_each = length(var.waf.disabled_rule_group) > 0 ? var.waf.disabled_rule_group : []
      iterator = each

      content {
        rule_group_name = each.value.name
        rules           = each.value.rules
      }
    }

    dynamic "exclusion" {
      for_each = length(var.waf.exclusion) > 0 ? var.waf.exclusion : []
      iterator = each

      content {
        match_variable          = each.value.match_variable
        selector_match_operator = each.value.selector_match_operator
        selector                = each.value.selector
      }
    }
  }

  ssl_policy {
    policy_name          = local.ssl_policy_name
    policy_type          = var.ssl_policy.policy_type
    disabled_protocols   = local.ssl_disabled_protocols
    min_protocol_version = var.ssl_policy.min_tls_version
    cipher_suites        = var.ssl_policy.cipher_suites
  }

  dynamic "ssl_certificate" {
    for_each = length(var.ssl_certificates) > 0 ? var.ssl_certificates : []
    iterator = each

    content {
      name                = each.value.name
      data                = each.value.data
      password            = each.value.password
      key_vault_secret_id = each.value.kv_secret_id
    }
  }

  dynamic "probe" {
    for_each = length(var.probes) > 0 ? var.probes : []
    iterator = each

    content {
      name                                      = each.value.name
      host                                      = each.value.phnfbts == false || each.value.phnfbts == null ? each.value.host : null
      protocol                                  = each.value.protocol
      path                                      = each.value.path
      port                                      = each.value.port
      interval                                  = each.value.interval
      timeout                                   = each.value.timeout
      unhealthy_threshold                       = each.value.unhealthy_threshold
      pick_host_name_from_backend_http_settings = each.value.phnfbts
      minimum_servers                           = each.value.min_servers

      dynamic "match" {
        for_each = each.value.match == null ? [] : [1]

        content {
          status_code = each.value.match.status_code
          body        = each.value.match.body
        }
      }
    }
  }

  dynamic "custom_error_configuration" {
    for_each = length(var.custom_errors) > 0 ? var.custom_errors : []
    iterator = each

    content {
      status_code           = each.value.status_code
      custom_error_page_url = each.value.page_url
    }
  }

  lifecycle {
    ignore_changes = [tags, location]
  }
}

resource "azurerm_management_lock" "pipa_lock" {
  depends_on = [azurerm_application_gateway.agw]
  count      = var.lock_resource ? 1 : 0

  name       = "CanNotDelete"
  scope      = azurerm_application_gateway.agw.id
  lock_level = "CanNotDelete"
  notes      = "Terraform: This prevents accidental deletion of this resource."

  lifecycle {
    ignore_changes = [name, notes]
  }
}