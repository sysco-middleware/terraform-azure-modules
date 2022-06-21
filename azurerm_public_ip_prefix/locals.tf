locals {
  zones = var.sku != "Standard" ? null : var.avail_zones
}