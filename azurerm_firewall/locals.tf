locals {
  # (Optional) The operation mode for threat intelligence-based filtering. Possible values are: Off, Alert,Deny and ""(empty string). Defaults to Alert.
  threat_intel_mode = var.sku_name == "AZFW_Hub" ? "" : var.threat_intel_mode
}