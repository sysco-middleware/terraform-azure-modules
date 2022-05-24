resource "azurerm_user_assigned_identity" "uai" {
  depends_on = [data.azurerm_resource_group.rg]

  name                = local.uai_name
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location

  lifecycle {
    ignore_changes = [tags, location]
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_gateway
resource "azurerm_application_gateway" "agw" {
  depends_on = [azurerm_user_assigned_identity.uai, data.azurerm_subnet.snet]

  name                = var.name
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  tags                = var.tags

  sku {
    name     = var.sku
    tier     = var.tier
    capacity = var.capacity
  }
  autoscale_configuration {
    max_capacity = var.max_capacity
    min_capacity = var.min_capacity
  }

  gateway_ip_configuration {
    name      = "${var.name}-ip-configuration"
    subnet_id = data.azurerm_subnet.snet.id # (Required) The ID of the Subnet which the Application Gateway should be connected to.
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = data.azurerm_public_ip.pipa.id #  (Optional) The ID of a Public IP Address which the Application Gateway should use. The allocation method for the Public IP Address depends on the sku of this Application Gateway. Please refer to the Azure documentation for public IP addresses for details.
  }

  dynamic "backend_address_pool" {
    for_each = length(var.backend_address_pool) > 0 ? var.backend_address_pool : []
    iterator = each

    content {
      name         = each.value.name
      ip_addresses = each.value.ip_addresses
      fqdn         = each.value.fqdn
    }
  }

  dynamic "backend_http_settings" {
    for_each = length(var.backend_http_settings) > 0 ? var.backend_http_settings : []
    iterator = each

    content {
      name                                 = each.value.name
      cookie_based_affinity                = each.value.cookie_based_affinity # "Disabled"
      affinity_cookie_name                 = each.value.affinity_cookie_name  # "ApplicationGatewayAffinity"
      port                                 = each.value.port                  # 443
      protocol                             = each.value.protocol              # "Https"
      request_timeout                      = each.value.request_timeout       # 10
      path                                 = each.value.path                  #"/path"
      probe_name                           = each.value.probe_name            # "probetest01abc"
      host_name                            = each.value.phnfba ? null : each.value.host_name
      pick_host_name_from_backend_addresss = each.value.phnfba
      trusted_root_certificate_names       = each.value.trcn

      dynamic "authentication_certificate" {
        for_each = length(each.value.auth_certificates) > 0 ? each.value.auth_certificates : []
        iterator = eachsub

        content {
          name = eachsub.value.name
          data = eachsub.value.data
        }
      }

      connection_draining {
        enabled           = each.value.connection_draining.enabled
        drain_timeout_sec = each.value.connection_draining.drain_timeout_sec
      }
    }

  }

  #authentication_certificate {
  #  name = local.auth_cert_name
  #  data = file(var.cert_file)
  # }
  rewrite_rule_set {
    name = local.rewrite_rule_set_name
    dynamic "rewrite_rule" {
      for_each = var.rewrite_rules
      iterator = each
      content {
        name          = each.value.name
        rule_sequence = each.value.rule_sequence
        # TODO:
      }

    }
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "https"
    host_names                     = var.host_names
    ssl_certificate_name           = var.ssl_cert_name #(Optional) The name of the associated SSL Certificate which should be used for this HTTP Listener.
    # custom_error_configuration - (Optional) One or more custom_error_configuration blocks as defined below.
    # firewall_policy_id - (Optional) The ID of the Web Application Firewall Policy which should be used for this HTTP Listener.
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }

  waf_configuration {
    enabled          = can(regex(var.tier, "WAF")) ? true : false
    firewall_mode    = "Detection"
    rule_set_version = "3.0"
  }

  identity {
    type         = "UserAssigned"                          #  (Optional) The Managed Service Identity Type of this Application Gateway. The only possible value is UserAssigned. Defaults to UserAssigned
    identity_ids = [azurerm_user_assigned_identity.uai.id] #concat([azurerm_user_assigned_identity.uai.id], var.identity_ids)
  }
  ssl_policy {
    policy_type          = "Custom"
    min_protocol_version = "TLSv1_2"

    cipher_suites = ["TLS_RSA_WITH_AES_128_GCM_SHA256", "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384", "TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA", "TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384", "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384", "TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA", "TLS_RSA_WITH_AES_256_GCM_SHA384", "TLS_RSA_WITH_AES_256_CBC_SHA256", "TLS_RSA_WITH_AES_256_CBC_SHA"]
  }

  ssl_certificate {
    name                = var.ssl_cert_name
    key_vault_secret_id = var.kv_secret_id # (Optional) Secret Id of (base-64 encoded unencrypted pfx) Secret or Certificate object stored in Azure KeyVault. You need to enable soft delete for keyvault to use this feature. Required if data is not set.
    #data     = filebase64("testdata/application_gateway_test.pfx") # (Optional) PFX certificate. Required if key_vault_secret_id is not set.
    ##password = "terraform" # (Optional) Password for the pfx file specified in data. Required if data is set
  }

  /*
  probe {
    name                = "probetest01abc"
    host                = "azure.com"
    protocol            = "Https"
    path                = "/"
    interval            = "30"
    timeout             = "300"
    unhealthy_threshold = "3"

    match {
      status_code = ["200-699"]
      body        = ""
    }
  }
  */

  lifecycle {
    ignore_changes = [tags, location]
  }
}

