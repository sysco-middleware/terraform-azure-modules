variable "rg_name" {}
variable "dns_name" {
  type        = string
  description = "(Required) The name of the Private DNS Zone. Must be a valid domain name."

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]+\\.[a-z]{2,}$|^[a-z][a-z0-9-_]+\\.[a-z0-9-]+\\.[a-z]{2,}$", var.dns_name))
    error_message = "The variable 'dns_name' must a valid domain name, ex name.domain.local or domain.local."
  }
}
variable "email_contact" {
  type        = string
  description = "(Required) The email contact for the SOA record."
}
variable "ttl" {
  type        = number
  description = "(Optional) The Time To Live of the SOA Record in seconds. Defaults to 3600"
  default     = 3600
}
variable "vnet_enabled" {
  type        = bool
  description = "Activates Virtual network connection. This require var.vnet_id to be true"
  default     = false
}
variable "vnet_id" {
  type        = string
  description = "Virtual Network ID of which the private DNS zone is connected to. Requires var.vnet_enabled to true"
  default     = "none"
}
variable "vnet_registration_enabled" {
  type        = bool
  description = "(Optional) Is auto-registration of virtual machine records in the virtual network in the Private DNS zone enabled? Defaults to false."
  default     = false
}
variable "dns_a_records" {
  type = list(object({
    name    = string
    ttl     = number
    records = list(string)
  }))
  description = "(Required) The name of the DNS A Record, with Time To Live (TTL) and the list of IPv4 Addresses."
  default     = []

  validation {
    condition = alltrue([
      for item in var.dns_a_records : can(regex("^[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}$", item.records))
    ])
    error_message = "The DNS record must be a valid IP address."
  }
}

variable "dns_cname_records" {
  type = list(object({
    name   = string
    ttl    = number
    record = string
  }))
  description = "(Required) The name of the DNS CNAME Record, with Time To Live (TTL) and the target of the CNAME.."
  default     = []
}

variable "dns_txt_records" {
  type = list(object({
    name  = string
    ttl   = number
    value = string
  }))
  description = "(Required) The name of the DNS TXT Record, Time To Live (TTL) and the value of the TXT record ( Max length: 1024 characters)."
  default     = []
}
