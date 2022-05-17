locals {
  interpreter        = ["PowerShell", "-Command"]
  asvnsc_win_apps_wa = var.asvnsc_snet_name_wa == null ? [] : var.asvnsc_win_apps_wa
  asvnsc_win_apps_fa = var.asvnsc_snet_name_fa == null ? [] : var.asvnsc_win_apps_fa
  asvnsc_lin_apps_wa = var.asvnsc_snet_name_wa == null ? [] : var.asvnsc_lin_apps_wa
  asvnsc_lin_apps_fa = var.asvnsc_snet_name_fa == null ? [] : var.asvnsc_lin_apps_fa
}
