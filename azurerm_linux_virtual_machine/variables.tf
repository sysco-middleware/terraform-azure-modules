variable "name" {
  description = "(Required) The name of the Linux Virtual Machine. Changing this forces a new resource to be created."
}
variable "lock_resource" {
  type        = bool
  description = "Adds lock level CanNotDelete to the resource"
  default     = false
}
variable "rg_name" {}
variable "kv_name" {}
variable "kv_cert_name" {}
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
variable "computer_name" {
  type        = string
  description = "(Optional) Specifies the Hostname which should be used for this Virtual Machine. If unspecified this defaults to the value for the name field. If the value of the name field is not a valid computer_name, then you must specify computer_name. Changing this forces a new resource to be created."
  default     = null
}
variable "admin_user" {
  type        = string
  description = "(Required) Specifies the name of the local administrator account."
}
variable "admin_pass" {
  type        = string
  description = "(Optional) The Password which should be used for the local-administrator on this Virtual Machine. Changing this forces a new resource to be created."
}
variable "disable_password_authentication" {
  type        = bool
  description = "(Optional) The Password which should be used for the local-administrator on this Virtual Machine. Changing this forces a new resource to be created."
  default     = true
}
variable "disable_password_authentication" {
  description = "Should Password Authentication be disabled on this Virtual Machine Scale Set? Defaults to false."
  default     = false
}
variable "generate_admin_ssh_key" {
  description = "Generates a secure private key and encodes it as PEM."
  default     = false
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
variable "allow_extension_operations" {
  type        = bool
  description = "(Optional) Should Extension Operations be allowed on this Virtual Machine?"
  default     = true
}
variable "disk_encryption_enabled" {
  type        = string
  description = "(Optional) Should all of the disks (including the temp disk) attached to this Virtual Machine be encrypted by enabling Encryption at Host?"
  default     = false
}
variable "source_image" {
  type        = string
  description = "The Linux distribution name. Choose between debian, centos, sles, redhat, opensuse, ubuntu."
  default     = "debian"
  validation {
    condition     = can(regex("^debian$|^centos$|^sles$|^redhat$|^opensuse$|^ubuntu$", var.source_image))
    error_message = "The variable 'source_image' must be: debian, centos, sles, redhat, opensuse, or ubuntu."
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
variable "size" {
  type        = string
  description = "(Required) The SKU which should be used for this Virtual Machine, such as Standard_F2."
  default     = "Standard_DS2_v2"
}
variable "ultra_ssd_enabled" {
  type        = bool
  description = "Optional) Should the capacity to enable Data Disks of the UltraSSD_LRS storage account type be supported on this Virtual Machine? Defaults to false."
  default     = false
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
variable "timezone" {
  # https://jackstromberg.com/2017/01/list-of-time-zones-consumed-by-azure/
  type        = string
  description = "(Optional) Specifies the time zone of the virtual machine"
  default     = "W. Europe Standard Time"
}
variable "sa_endpoint" {
  type        = string
  description = "(Optional) The Primary/Secondary Endpoint for the Azure Storage Account which should be used to store Boot Diagnostics, including Console Output and Screenshots from the Hypervisor. Default null value will utilize a Managed Storage Account to store Boot Diagnostics."
  default     = null
}
variable "patch_mode" {
  type        = string
  description = "(Optional) Specifies the mode of in-guest patching to this Linux Virtual Machine. Possible values are AutomaticByPlatform and ImageDefault. Defaults to ImageDefault"
  default     = "ImageDefault"
  validation {
    condition     = can(regex("^ImageDefault$|^AutomaticByPlatform$", var.patch_mode))
    error_message = "The variable 'patch_mode' must be: ImageDefault (default) or AutomaticByPlatform."
  }
}
variable "provision_vm_agent" {
  type        = bool
  description = "(Optional) Should the Azure VM Agent be provisioned on this Virtual Machine? Defaults to true. Changing this forces a new resource to be created."
  default     = true
}
variable "license_type" {
  type        = string
  description = "(Optional) Specifies the BYOL Type for this Virtual Machine. Possible values are RHEL_BYOS and SLES_BYOS."
  default     = null
}
variable "public_key_file" {
  type        = string
  description = "The Public Key file which should be used for authentication, which needs to be at least 2048-bit and in ssh-rsa format. One of either 'admin_pass' or 'public_key_file' must be specified.. Default is null"
  default     = null
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
    })

    file = object({        # https://www.terraform.io/language/resources/provisioners/file
      source      = string # This is the source file or folder. It can be specified as relative to the current working directory or as an absolute path. This attribute cannot be specified with content.
      content     = string # This is the content to copy on the destination. If destination is a file, the content will be written on that file, in case of a directory a file named tf-file-content is created. It's recommended to use a file as the destination. A template_file might be referenced in here, or any interpolation syntax. This attribute cannot be specified with source.
      destination = string # (Required) This is the destination path. It must be specified as an absolute path.
    })
  }))
  default = []
}

variable "tags" {
  type        = map(any)
  description = "A mapping of tags to assign to the resource."
  default     = {}
}