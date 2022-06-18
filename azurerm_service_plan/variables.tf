variable "name" {}
variable "rg_name" {}
variable "os_type" {
  type        = string
  description = "(Required) The O/S type for the App Services to be hosted in this plan. Possible values include Windows, Linux, and WindowsContainer."
  default     = "Windows"
  validation {
    condition     = can(regex("Windows|Linux|WindowsContainer", var.os_type))
    error_message = "Variable 'os_type' must either be Windows (Default), Linux, or WindowsContainer."
  }
}
variable "per_site_scaling_enabled" {
  type        = bool
  description = "Is Per Site Scaling be enabled? Default is false"
  default     = false
}
variable "zone_balancing_enabled" {
  type        = bool
  description = "Is the Service Plan balance across Availability Zones in the region? Default is false. https://docs.microsoft.com/en-us/azure/app-service/how-to-zone-redundancy"
  default     = false
}
variable "sku_name" {
  type        = string
  description = "(Required) The SKU for the plan. Possible values include B1, B2, B3, D1, F1, FREE, I1, I2, I3, I1v2, I2v2, I3v2, P1v2, P2v2, P3v2, P1v3, P2v3, P3v3, S0, S1, S2, S3, SHARED, Y1, EP1, EP2, EP3, WS1, WS2, and WS3."
  validation {
    condition     = can(regex("B1|B2|B3|D1|F1|FREE|I1|I2|I3|I1v2|I2v2|I3v2|P1v2|P2v2|P3v2|P1v3|P2v3|P3v3|S1|S2|S3|SHARED|Y1|EP1|EP2|EP3|WS1|WS2|WS3", var.sku_name))
    error_message = "Variable 'sku_name' must either be B1, B2, B3, D1, F1, FREE, I1, I2, I3, I1v2, I2v2, I3v2, P1v2 (Default), P2v2, P3v2, P1v3, P2v3, P3v3, S1, S2, S3, SHARED, Y1, EP1, EP2, EP3, WS1, WS2, and WS3."
  }
}
variable "app_service_environment_id" {
  type        = string
  description = "(Optional) The ID of the App Service Environment to create this Service Plan in."
  default     = null
}
variable "worker_count" {
  type        = number
  description = "(Optional) The number of Workers (instances) to be allocated. The value must be at least 4."
  default     = 4
  validation {
    condition     = var.worker_count >= 4
    error_message = "Variable 'worker_count' must be 3 or higher than maximum_elastic_worker_count."
  }
}
variable "maximum_elastic_worker_count" {
  type        = number
  description = "(Optional) The maximum number of workers to use in an Elastic SKU Plan. Cannot be set unless using an Elastic SKU. The value must beat least 1 and less than NumberOfWorkers"
  default     = 2
  validation {
    condition     = var.maximum_elastic_worker_count <= 3
    error_message = "Variable 'maximum_elastic_worker_count' must be 3 and lower that worker_count."
  }
}

variable "tags" {
  type        = map(any)
  description = "A mapping of tags to assign to the resource."
  default     = {}
}
