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
variable "ppg_id" {
  type        = string
  description = "(Optional) The ID of the Proximity Placement Group which the Virtual Machine should be assigned to. Default is null."
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
variable "assign_public_ip_to_each_vm_in_vmss" {
  description = "Create a virtual machine scale set that assigns a public IP address to each VM"
  default     = false
}
variable "network_interfaces" {
  type = list(object({
    dns_servers                   = list(string)
    enable_accelerated_networking = bool
    enable_ip_forwarding          = bool
    ip_configuration = list(object({
      name                         = string
      agw_backend_address_pool_ids = list(string) # (Optional) A list of Backend Address Pools ID's from a Application Gateway which this Virtual Machine Scale Set should be connected to.
      asg_ids                      = list(string) # (Optional) A list of Application Security Group ID's which this Virtual Machine Scale Set should be connected to.
      lb_backend_ids               = list(string) # (Optional) A list of Backend Address Pools ID's from a Load Balancer which this Virtual Machine Scale Set should be connected to.
      lb_onbound_nat_rules_ids     = list(string) # (Optional) A list of NAT Rule ID's from a Load Balancer which this Virtual Machine Scale Set should be connected to.
      primary                      = bool
      public_ip_address = object({
        name                    = string # (Required) The Name of the Public IP Address Configuration.
        domain_name_label       = string # (Optional) The Prefix which should be used for the Domain Name Label for each Virtual Machine Instance. Azure concatenates the Domain Name Label and Virtual Machine Index to create a unique Domain Name Label for each Virtual Machine.
        idle_timeout_in_minutes = number # (Optional) The Idle Timeout in Minutes for the Public IP Address. Possible values are in the range 4 to 32.
        ip_tag = object({
          tag  = string # The IP Tag associated with the Public IP, such as SQL or Storage.
          type = string # The Type of IP Tag, such as FirstPartyUsage.
        })
        public_ip_prefix_id = string # (Optional) The ID of the Public IP Address Prefix from where Public IP Addresses should be allocated. Changing this forces a new resource to be created
      })
      subnet_id = string #  (Optional) The ID of the Subnet which this IP Configuration should be connected to. Subnet_id is required if version is set to IPv4
      version   = string #  (Optional) The Internet Protocol Version which should be used for this IP Configuration. Possible values are IPv4 and IPv6. Defaults to IPv4
    }))
    name                      = string
    network_security_group_id = bool
    primary                   = bool # If multiple network_interface blocks are specified, one must be set to primary
  }))
  description = "(Required) One or more ip_configuration blocks as defined below"
  default = [{
    name    = "Ethernet0"
    primary = true
    ip_configuration = [{
      agw_backend_address_pool_ids = []
      asg_ids                      = []
      lb_backend_ids               = []
      lb_onbound_nat_rules_ids     = []
      name                         = "internal"
      primary                      = true
      public_ip_address = {
        domain_name_label       = null
        idle_timeout_in_minutes = 4
        name                    = "PublicIP"
        ip_tag = {
          tag  = null
          type = null
        }
        public_ip_prefix_id = null
      }
      subnet_id = null
      version   = "IPv4"
    }]
    dns_servers                   = []
    enable_accelerated_networking = false
    enable_ip_forwarding          = false
    network_security_group_id     = null
  }]
}

variable "instances" {
  type        = number
  description = "(Required) The number of Virtual Machines in the Scale Set."
  default     = 1
}
variable "admin_user" {
  type        = string
  description = "(Required) Specifies the name of the local administrator account."
}
variable "admin_pass" {
  type        = string
  description = "(Required for Windows, Optional for Linux) The password associated with the local administrator account."
}
variable "sku" {
  type        = string
  description = " (Required) The Virtual Machine SKU for the Scale Set, such as Standard_F2."
  default     = "Standard_F2"
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
variable "disk_name" {
  type        = string
  description = "OS disk name"
  default     = "system"
}
variable "computer_name_prefix" {
  type        = string
  description = " (Optional) The prefix which should be used for the name of the Virtual Machines in this Scale Set. If unspecified this defaults to the value for the name field. If the value of the name field is not a valid computer_name_prefix, then you must specify computer_name_prefix."
  default     = null
}
variable "health_probe_id" {
  type        = string
  description = "(Optional) The ID of a Load Balancer Probe which should be used to determine the health of an instance. This is Required and can only be specified when upgrade_mode is set to Automatic or Rolling."
  default     = null
}
variable "timezone" {
  # https://jackstromberg.com/2017/01/list-of-time-zones-consumed-by-azure/
  type        = string
  description = "(Optional) Specifies the time zone of the virtual machine"
  default     = "Central Europe Standard Time"
}
variable "zone_balance" {
  type        = bool
  description = "(Optional) Should the Virtual Machines in this Scale Set be strictly evenly distributed across Availability Zones? Defaults to false. Changing this forces a new resource to be created."
  default     = true
}
variable "zones" {
  type        = list(number)
  description = "(Optional) A list of Availability Zones in which the Virtual Machines in this Scale Set should be created in. Changing this forces a new resource to be created."
  default     = [1, 2, 3]
}
variable "license_type" {
  type        = string
  description = "(Optional) Specifies the type of on-premise license (also known as Azure Hybrid Use Benefit) which should be used for this Virtual Machine. Possible values are None, Windows_Client and Windows_Server."
  default     = "None"
}
variable "disk_encryption_enabled" {
  type        = string
  description = "(Optional) Should all of the disks (including the temp disk) attached to this Virtual Machine be encrypted by enabling Encryption at Host?"
  default     = false
}
variable "os_disk" {
  type = object({
    caching                   = string # (Required) The Type of Caching which should be used for the Internal OS Disk. Possible values are None, ReadOnly and ReadWrite
    storage_account_type      = string # (Required) The Type of Storage Account which should back this the Internal OS Disk. Possible values are Standard_LRS, StandardSSD_LRS, Premium_LRS. Changing this forces a new resource to be created.
    disk_encryption_set_id    = string # The Disk Encryption Set must have the Reader Role Assignment scoped on the Key Vault - in addition to an Access Policy to the Key Vault
    disk_size_gb              = number # (Optional) The Size of the Internal OS Disk in GB, if you wish to vary from the size used in the image this Virtual Machine is sourced from.
    write_accelerator_enabled = bool   # (Optional) Should Write Accelerator be Enabled for this OS Disk? This requires that the storage_account_type is set to Premium_LRS and that caching is set to None.
  })
  description = ""
  default = {
    caching                   = "ReadWrite"
    storage_account_type      = "Standard_LRS"
    disk_encryption_set_id    = null
    disk_size_gb              = 50
    write_accelerator_enabled = false
  }
  validation {
    condition     = can(regex("^Standard_LRS$|^StandardSSD_LRS$|^Premium_LRS$", var.os_disk.storage_account_type))
    error_message = "The variable 'os_disk' must have value storage_account_type: Standard_LRS (default), StandardSSD_LRS, or Premium_LRS."
  }
}
variable "data_disks" {
  type = list(object({
    caching              = string # (Required) The Type of Caching which should be used for the Internal OS Disk. Possible values are None, ReadOnly and ReadWrite
    lun                  = number # (Required) The Logical Unit Number of the Data Disk, which must be unique within the Virtual Machine.
    storage_account_type = string # (Required) The Type of Storage Account which should back this Data Disk. Possible values include Standard_LRS, StandardSSD_LRS, Premium_LRS and UltraSSD_LRS.
    create_option        = string # (Optional) The create option which should be used for this Data Disk. Possible values are Empty and FromImage. Defaults to Empty. (FromImage should only be used if the source image includes data disks).

    disk_encryption_set_id    = string # (Optional) The ID of the Disk Encryption Set which should be used to encrypt this Data Disk. Must have the Reader Role Assignment scoped on the Key Vault -
    disk_size_gb              = number # (Required) The size of the Data Disk which should be created.
    write_accelerator_enabled = bool   # (Optional) Should Write Accelerator be enabled for this Data Disk? Defaults to false.
    # TODO: disk_iops_read_write = number # (Optional) Specifies the Read-Write IOPS for this Data Disk. Only settable for UltraSSD disks.
    # TODO: disk_mbps_read_write = number # (Optional) Specifies the bandwidth in MB per second for this Data Disk. Only settable for UltraSSD disks.
  }))
  description = ""
  default     = []
  validation {
    condition = alltrue([
      for item in var.data_disks : can(regex("^Standard_LRS$|^StandardSSD_LRS$|^Premium_LRS$|^UltraSSD_LRS$", item.storage_account_type))
    ])
    error_message = "The variable 'data_disks' must have value storage_account_type: Standard_LRS (default), StandardSSD_LRS, Premium_LRS, or UltraSSD_LRS."
  }
}
variable "enable_automatic_updates" {
  type        = bool
  description = "(Optional) Specifies if Automatic Updates are Enabled for the Windows Virtual Machine. Changing this forces a new resource to be created."
  default     = true
}
variable "upgrade_mode" {
  type        = string
  description = "(Optional) Specifies how Upgrades (e.g. changing the Image/SKU) should be performed to Virtual Machine Instances. Possible values are Automatic, Manual and Rolling. Defaults to Manual"
  default     = "Manual"
  validation {
    condition     = can(regex("^Manual$|^Rolling$|^Automatic$", var.upgrade_mode))
    error_message = "The variable 'upgrade_mode' must be: Manual (default), Automatic, or Rolling."
  }
}
variable "automatic_os_upgrade_policy" {
  type = object({
    disable_automatic_rollback  = bool # (Required) Should automatic rollbacks be disabled?
    enable_automatic_os_upgrade = bool # (Required) Should OS Upgrades automatically be applied to Scale Set instances in a rolling fashion when a newer version of the OS Image becomes available?
  })
  description = "Automatic OS Upgrade Policy"
  default = {
    disable_automatic_rollback  = false
    enable_automatic_os_upgrade = true
  }
}
variable "rolling_upgrade_policy" {
  type = object({
    max_batch_instance_percent              = number # (Required) The maximum percent of total virtual machine instances that will be upgraded simultaneously by the rolling upgrade in one batch. As this is a maximum, unhealthy instances in previous or future batches can cause the percentage of instances in a batch to decrease to ensure higher reliability.
    max_unhealthy_instance_percent          = number # (Required) The maximum percentage of the total virtual machine instances in the scale set that can be simultaneously unhealthy, either as a result of being upgraded, or by being found in an unhealthy state by the virtual machine health checks before the rolling upgrade aborts. This constraint will be checked prior to starting any batch.
    max_unhealthy_upgraded_instance_percent = number # (Required) The maximum percentage of upgraded virtual machine instances that can be found to be in an unhealthy state. This check will happen after each batch is upgraded. If this percentage is ever exceeded, the rolling update aborts.
    pause_time_between_batches              = string # (Required) The wait time between completing the update for all virtual machines in one batch and starting the next batch. The time duration should be specified in ISO 8601 format.
  })
  description = "Enabling automatic OS image upgrades on your scale set helps ease update management by safely and automatically upgrading the OS disk for all instances in the scale set."
  default = {
    max_batch_instance_percent              = 20
    max_unhealthy_instance_percent          = 20
    max_unhealthy_upgraded_instance_percent = 20
    pause_time_between_batches              = "PT0S"
  }
}
variable "automatic_instance_repair" {
  type = object({
    enabled      = bool   #  (Required) Should the automatic instance repair be enabled on this Virtual Machine Scale Set?
    grace_period = string # (Optional) Amount of time (in minutes, between 30 and 90, defaults to 30 minutes) for which automatic repairs will be delayed. The grace period starts right after the VM is found unhealthy. The time duration should be specified in ISO 8601 format.
  })
  description = "Automatic OS Upgrade Policy"
  default = {
    enabled      = false
    grace_period = "PT30M"
  }
}

variable "ephemeral_disk_support" {
  type        = bool
  description = "VMs and VM Scale Set Instances using an ephemeral OS disk support only Readonly caching"
  default     = false
}
variable "provision_vm_agent" {
  type        = bool
  description = "(Optional) Should the Azure VM Agent be provisioned on this Virtual Machine? Defaults to true. Changing this forces a new resource to be created."
  default     = true
}

variable "provisioners" {
  type = list(object({
    connection = object({
      bastion_user     = string
      bastion_password = string
      bastion_host     = string
      host             = string
    })
    inline  = list(string)
    script  = string
    scripts = list(string)
    file = object({        # https://www.terraform.io/language/resources/provisioners/file
      source      = string # This is the source file or folder. It can be specified as relative to the current working directory or as an absolute path. This attribute cannot be specified with content.
      content     = string # This is the content to copy on the destination. If destination is a file, the content will be written on that file, in case of a directory a file named tf-file-content is created. It's recommended to use a file as the destination. A template_file might be referenced in here, or any interpolation syntax. This attribute cannot be specified with source.
      destination = string #  (Required) This is the destination path. It must be specified as an absolute path.
    })
  }))
  description = "Provisioner invokes a script on a remote resource after it is created. Scripts and Script does not support argument, use inline for that."
  default     = []
}
variable "tags" {
  type        = map(any)
  description = "A mapping of tags to assign to the resource."
  default     = {}
}

