locals {
  enable_partitioning = var.sku == "Premium" ? true : false
  capacity            = can(regex("Basic|Standard", var.sku)) ? 0 : var.capacity
  zone_redundant      = can(regex("Premium", var.sku)) ? var.zone_redundant : false
}