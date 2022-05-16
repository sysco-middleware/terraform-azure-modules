variable "name" {}
variable "lock_resource" {
  type        = bool
  description = "Adds lock level CanNotDelete to the resource"
  default     = false
}
variable "rg_name" {}
variable "kv_name" {}
variable "kv_cert_name" {}
variable "sa_blob_endpoint" {
  type        = string
  description = "(Optional) The Primary/Secondary Endpoint for the Azure Storage Account which should be used to store Boot Diagnostics, including Console Output and Screenshots from the Hypervisor. Default null value will utilize a Managed Storage Account to store Boot Diagnostics."
  default     = null
}
variable "nic_ids" {
  type        = list(string)
  description = "(Required). A list of Network Interface ID's which should be attached to this Virtual Machine. The first Network Interface ID in this list will be the Primary Network Interface on the Virtual Machine."
}
variable "vmss_id" {
  type        = string
  description = "(Optional) Specifies the Orchestrated Virtual Machine Scale Set that this Virtual Machine should be created within. Changing this forces a new resource to be created. Default is null"
  default     = null
}
variable "ppg_id" {
  type        = string
  description = "(Optional) The ID of the Proximity Placement Group which the Virtual Machine should be assigned to. Default is null."
  default     = null
}
variable "as_id" {
  type        = string
  description = "(Optional) Specifies the ID of the Availability Set in which the Virtual Machine should exist. Changing this forces a new resource to be created. Default is null"
  default     = null
}
variable "managed_identity_type" {
  type        = string
  description = "(Optional) The type of Managed Identity which should be assigned to the Linux Virtual Machine Scale Set. Possible values are `SystemAssigned`, `UserAssigned` and `SystemAssigned, UserAssigned`"
  default     = null
  validation {
    condition     = can(regex("^SystemAssigned$|^UserAssigned$|^SystemAssigned, UserAssigned$", var.managed_identity_type))
    error_message = "The variable 'managed_identity_type' must be: SystemAssigned, or UserAssigned or `SystemAssigned, UserAssigned`."
  }
}
variable "managed_identity_ids" {
  type        = list(string)
  description = "(Optional) Specifies a list of User Assigned Managed Identity IDs to be assigned to this Windows Virtual Machine Scale Set."
  default     = []
}
variable "size" {
  type        = string
  description = "(Required) Specifies the size of the Virtual Machine. See also Azure VM Naming Conventions. https://docs.microsoft.com/en-us/azure/virtual-machines/dv2-dsv2-series"
  default     = "Standard_DS2_v2"
}
variable "source_image" {
  type        = string
  description = "The Windows server name. Choose between W2019, W2016, W2012R2, W2012, W2008R2. Default is W2019"
  default     = "W2019"
  validation {
    condition     = can(regex("^W2019$|^W2016$|^W2012R2$|^W2012$|^W2008R2$", var.source_image))
    error_message = "The variable 'source_image' must be: W2019, W2016, W2012R2, W2012, or W2008R2."
  }
}
variable "source_image_id" {
  type        = string
  description = "(Optional) The ID of the Image which this Virtual Machine should be created from. This replaces 'source_image'. Changing this forces a new resource to be created."
  default     = null
}
variable "os_disk" {
  type = object({
    name                      = string # (Optional) The name which should be used for the Internal OS Disk. Changing this forces a new resource to be created.
    caching                   = string # (Required) The Type of Caching which should be used for the Internal OS Disk. Possible values are None, ReadOnly and ReadWrite
    storage_account_type      = string # (Required) The Type of Storage Account which should back this the Internal OS Disk. Possible values are Standard_LRS, StandardSSD_LRS, Premium_LRS, StandardSSD_ZRS and Premium_ZRS. Changing this forces a new resource to be created.
    disk_encryption_set_id    = string # The Disk Encryption Set must have the Reader Role Assignment scoped on the Key Vault - in addition to an Access Policy to the Key Vault
    disk_size_gb              = number # (Optional) The Size of the Internal OS Disk in GB, if you wish to vary from the size used in the image this Virtual Machine is sourced from.
    write_accelerator_enabled = bool   # (Optional) Should Write Accelerator be Enabled for this OS Disk? This requires that the storage_account_type is set to Premium_LRS and that caching is set to None.
  })
  description = "Operation System disk"
  default = {
    name                      = "Default"
    caching                   = "ReadWrite"
    storage_account_type      = "StandardSSD_LRS"
    disk_encryption_set_id    = null
    disk_size_gb              = 40
    write_accelerator_enabled = false
  }
  validation {
    condition     = can(regex("^Standard_LRS$|^StandardSSD_LRS$|^Premium_LRS$|^StandardSSD_ZRS$|^Premium_ZRS$", var.os_disk.storage_account_type))
    error_message = "The variable 'os_disk' must have value storage_account_type: Standard_LRS (default), StandardSSD_LRS, Premium_LRS, StandardSSD_ZRS or Premium_ZRS."
  }
}
variable "ephemeral_disk_support" {
  type        = bool
  description = "VMs and VM Scale Set Instances using an ephemeral OS disk support only Readonly caching"
  default     = false
}
variable "computer_name" {
  type        = string
  description = "(Optional) Specifies the Hostname which should be used for this Virtual Machine. If unspecified this defaults to the value for the name field. If the value of the name field is not a valid computer_name, then you must specify computer_name. Changing this forces a new resource to be created"
  default     = null
}
variable "admin_user" {
  type        = string
  description = "(Required) Specifies the name of the local administrator account."
}
variable "admin_pass" {
  type        = string
  description = "(Required) The password associated with the local administrator account."
  sensitive   = true
}
variable "timezone" {
  type        = string
  description = "(Optional) Specifies the time zone of the virtual machine. https://jackstromberg.com/2017/01/list-of-time-zones-consumed-by-azure/"
  default     = "Central Europe Standard Time"
}
variable "patch_mode" {
  type        = string
  description = "(Optional) Specifies the mode of in-guest patching to this Windows Virtual Machine. Possible values are Manual, AutomaticByOS and AutomaticByPlatform. Defaults to AutomaticByOS."
  default     = "AutomaticByOS"
  validation {
    condition     = can(regex("^Manual$|^AutomaticByOS$|^AutomaticByPlatform$", var.patch_mode))
    error_message = "The variable 'patch_mode' must be: Manual, AutomaticByOS (default) or AutomaticByPlatform."
  }
}
variable "priority" {
  type        = string
  description = "(Optional) Specifies the priority of this Virtual Machine. Possible values are Regular and Spot. Defaults to Regular. Changing this forces a new resource to be created."
  default     = "Regular"
  validation {
    condition     = can(regex("^Spot$|^Regular$", var.priority))
    error_message = "The variable 'priority' must be: Spot or Regular (default)."
  }
}
variable "disk_encryption_enabled" {
  type        = string
  description = "(Optional) Should all of the disks (including the temp disk) attached to this Virtual Machine be encrypted by enabling Encryption at Host?"
  default     = false
}
variable "enable_automatic_updates" {
  type        = bool
  description = "(Optional) Specifies if Automatic Updates are Enabled for the Windows Virtual Machine. Changing this forces a new resource to be created."
  default     = true
}
variable "provision_vm_agent" {
  type        = bool
  description = "(Optional) Should the Azure VM Agent be provisioned on this Virtual Machine? Defaults to true. Changing this forces a new resource to be created."
  default     = true
}
variable "unattend_content" {
  type = list(object({
    content = string # (Required) The XML formatted content that is added to the unattend.xml file for the specified path and component. Changing this forces a new resource to be created.
    setting = string # (Required) The name of the setting to which the content applies. Possible values are AutoLogon and FirstLogonCommands. Changing this forces a new resource to be created.
  }))
  description = "(Required) The XML formatted content that is added to the unattend.xml file for the specified path and component. Changing this forces a new resource to be created."
  default     = []
  validation {
    condition = alltrue([
      for item in var.unattend_content : can(regex("^AutoLogon$|^FirstLogonCommands$", item.setting))
    ])
    error_message = "The variable 'unattend_content' must use setting: AutoLogon or FirstLogonCommands."
  }
}
variable "sa_endpoint" {
  type        = string
  description = "(Optional) The Primary/Secondary Endpoint for the Azure Storage Account which should be used to store Boot Diagnostics, including Console Output and Screenshots from the Hypervisor. Default null value will utilize a Managed Storage Account to store Boot Diagnostics."
  default     = null
}
variable "license_type" {
  type        = string
  description = "(Optional) Specifies the type of on-premise license (also known as Azure Hybrid Use Benefit) which should be used for this Virtual Machine. Possible values are None, Windows_Client and Windows_Server."
  default     = "None"
}

variable "provisioners" {
  type = list(object({
    inline  = list(string)
    script  = string
    scripts = list(string)

    connection = object({
      bastion_host     = string
      bastion_user     = string
      bastion_password = string
      host             = string
    })

    file = object({        # https://www.terraform.io/language/resources/provisioners/file
      source      = string # This is the source file or folder. It can be specified as relative to the current working directory or as an absolute path. This attribute cannot be specified with content.
      content     = string # This is the content to copy on the destination. If destination is a file, the content will be written on that file, in case of a directory a file named tf-file-content is created. It's recommended to use a file as the destination. A template_file might be referenced in here, or any interpolation syntax. This attribute cannot be specified with source.
      destination = string #  (Required) This is the destination path. It must be specified as an absolute path.
    })
  }))
  description = "Provisioner invokes a scripts on a remote resource after it is created. Scripts and Script does not support argument, use inline for that."
  default     = []
}

variable "tags" {
  type        = map(any)
  description = "A mapping of tags to assign to the resource."
  default     = {}
}
