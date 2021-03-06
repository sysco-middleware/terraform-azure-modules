
locals {
  uai_install            = var.uai_id == null && local.is_sku_tier_v2
  ssl_disabled_protocols = var.ssl_policy.policy_name != null || var.ssl_policy.policy_type != null ? null : var.ssl_policy.disabled_protocols
  ssl_policy_name        = var.ssl_policy.policy_type == "Predefined" && var.ssl_policy.policy_name == null ? "Default" : var.ssl_policy.policy_name
  is_sku_tier_v2         = can(regex("Standard_v2|WAF_v2", var.tier)) ? true : false
  is_waf                 = can(regex("WAF", var.tier)) ? true : false
  kv_rbac_roles          = local.uai_install && var.kv_id != null ? ["Key Vault Secrets User"] : []
  uai_id                 = local.uai_install ? azurerm_user_assigned_identity.uai[0].id : var.uai_id
}
