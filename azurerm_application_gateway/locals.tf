
locals {
  uai_name               = "${var.name}-uai"
  ssl_disabled_protocols = var.ssl_policy.name != null || var.ssl_policy.name != null ? null : var.ssl_policy.disabled_tls
  ssl_policy_name        = var.ssl_policy.type == "Predefined" && var.ssl_policy.name == null ? "Default" : var.ssl_policy.name
}
