variable "name" {}
variable "lock_resource" {
  type        = bool
  description = "Adds lock level CanNotDelete to the resource"
  default     = false
}
variable "rg_name" {}
variable "prefix_length" {
  type        = number
  description = "(Optional) Specifies the number of bits of the prefix. Choices are 28(16 addresses), 29(8 addresses), 30(4 addresses) or 31(2 addresses). Changing this forces a new resource to be created."
  default     = 29
  validation {
    condition     = can(regex("28|29|30|31", var.prefix_length))
    error_message = "Variable 'prefix_length' must either be 28, 29 (Default), 30, 31."
  }
}
variable "ip_version" {
  type        = string
  description = "(Optional) The IP Version to use, IPv6 or IPv4. Changing this forces a new resource to be created. Default is IPv4"
  default     = "IPv4"
  validation {
    condition     = can(regex("IPv4|IPv6", var.ip_version))
    error_message = "Variable 'ip_version' must either be IPv4 (Default) or IPv6."
  }
}
variable "sku" {
  type        = string
  description = "(Optional) The SKU of the Public IP Prefix. Accepted values are Standard. Defaults to Standard. Changing this forces a new resource to be created"
  default     = "Standard"
  validation {
    condition     = can(regex("Standard", var.sku))
    error_message = "Variable 'sku' must be Standard."
  }
}
variable "avail_zones" {
  type        = list(number)
  description = "(Optional) Specifies a list of Availability Zones in which this Public IP Prefix should be located. Changing this forces a new Public IP Prefix to be created."
  default     = [1]
}
variable "tags" {
  type        = map(any)
  description = "A mapping of tags to assign to the resource."
  default     = {}
}
