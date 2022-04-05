locals {

  is_elastic                   = can(regex("EP1|EP2|EP3", local.sku_name)) # Used for Function Apps
  is_consumtion_plan           = can(regex("Y1", local.sku_name))          # Used for Function Apps
  maximum_elastic_worker_count = local.is_elastic ? var.maximum_elastic_worker_count : null

  is_isolated                   = can(regex("I1|I2|I3|I1v2|I2v2|I3v3", local.sku_name))
  app_service_environment_id    = local.is_isolated && can(regex("I1|I2|I3", var.app_service_environment_id)) ? var.app_service_environment_id : null
  app_service_environment_id_v3 = local.is_isolated && can(regex("I1v2|I2v2|I3v3", var.app_service_environment_id)) ? var.app_service_environment_id : null
}