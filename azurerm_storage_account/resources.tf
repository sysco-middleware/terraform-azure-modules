#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account
# https://github.com/aztfmod/terraform-azurerm-caf/blob/master/modules/storage_account/storage_account.tf
resource "azurerm_storage_account" "sa" {
  depends_on = [data.azurerm_resource_group.rg]

  name                              = var.name
  resource_group_name               = data.azurerm_resource_group.rg.name
  location                          = var.location == "" ? data.azurerm_resource_group.rg.location : var.location
  account_kind                      = var.account_kind
  account_tier                      = local.account_tier
  account_replication_type          = var.account_replication_type
  access_tier                       = var.access_tier
  enable_https_traffic_only         = true
  min_tls_version                   = var.min_tls_version
  large_file_share_enabled          = false
  allow_nested_items_to_be_public   = false
  infrastructure_encryption_enabled = local.infrastructure_encryption_enabled
  tags                              = var.tags

  # TODO: shared_access_key_enabled - Indicates whether the storage account permits requests to be authorized with the account access key via Shared Key. If false, then all requests, including shared access signatures, must be authorized with Azure Active Directory (Azure AD). The default value is true.
  # TODO: is_hns_enabled - (Optional) Is Hierarchical Namespace enabled? This can be used with Azure Data Lake Storage Gen 2 (see here for more information). Changing this forces a new resource to be created.


  # This is defined by a resource below
  network_rules {
    default_action             = var.network_rules.default_action
    ip_rules                   = local.is_selected_networks ? var.network_rules.ip_rules : []
    virtual_network_subnet_ids = local.is_selected_networks ? var.network_rules.virtual_network_subnet_ids : []
    bypass                     = local.is_selected_networks ? var.network_rules.bypass : []

    dynamic "private_link_access" {
      for_each = length(var.network_rules.private_link_access) > 0 ? var.network_rules.private_link_access : []
      iterator = each
      content {
        endpoint_resource_id = each.value.endpoint_resource_id
        endpoint_tenant_id   = each.value.endpoint_tenant_id
      }
    }
  }
  static_website {
    index_document = "index.html"
    #error_404_document = "404.html" #- (Optional) The absolute path to a custom webpage that should be used when a request is made which does not correspond to an existing file.
  }
  share_properties {
    retention_policy {
      days = var.retention_in_days
    }
    smb {
      versions             = toset(["SMB3.0", "SMB3.1.1"])
      authentication_types = toset(["NTLMv2", "Kerberos"])
    }
  }

  #azure_files_authentication {

  #}

  dynamic "identity" {
    for_each = var.managed_identity_type != null ? [1] : []
    content {
      type         = var.managed_identity_type
      identity_ids = local.identity_ids
    }
  }

  dynamic "blob_properties" {
    for_each = length(var.cors_rules) > 0 ? [1] : []
    content {
      dynamic "cors_rule" {
        for_each = var.cors_rules
        iterator = each
        content {
          allowed_headers    = each.value.allowed_headers    # (Required) A list of headers that are allowed to be a part of the cross-origin request.
          allowed_methods    = each.value.allowed_methods    # (Required) A list of http methods that are allowed to be executed by the origin. Valid options are DELETE, GET, HEAD, MERGE, POST, OPTIONS, PUT or PATCH.
          allowed_origins    = each.value.allowed_origins    # (Required) A list of origin domains that will be allowed by CORS.
          exposed_headers    = each.value.exposed_headers    # (Required) A list of response headers that are exposed to CORS clients.  
          max_age_in_seconds = each.value.max_age_in_seconds #  (Required) The number of seconds the client should cache a preflight response.
        }
      }
      delete_retention_policy {
        days = var.retention_in_days # Optional) Specifies the number of days that the blob should be retained, between 1 and 365 days. Defaults to 7
      }
      last_access_time_enabled = true
      container_delete_retention_policy {
        days = var.retention_in_days # (Optional) Specifies the number of days that the container should be retained, between 1 and 365 days. Defaults to 7.
      }
      versioning_enabled  = true
      change_feed_enabled = true
    }
  }
  #dynamic "queue_properties" {
  #for_each = can(regex("StorageV2|BlockBlogStorage",var.account_kind) ? [] : [1]
  #}
  #custom_domain {
  #name = var.custom_domain #  (Required) The Custom Domain Name to use for the Storage Account, which will be validated by Azure.
  #use_subdomain - (Optional) Should the Custom Domain Name be validated by using indirect CNAME validation?
  #}

  routing {
    publish_internet_endpoints  = false
    publish_microsoft_endpoints = false
    choice                      = "MicrosoftRouting"
  }

  provisioner "local-exec" {
    command    = "echo Provisioned ${self.name}"
    on_failure = continue
  }

  provisioner "local-exec" {
    when    = destroy
    command = "echo 'Destroyed ${self.name}'"
  }

  lifecycle {
    ignore_changes = [tags["updated_date"], location, resource_group_name, queue_encryption_key_type, table_encryption_key_type, infrastructure_encryption_enabled] # Must have this or else the resource will be replaced
  }
}

///////////////////////////////////////////////////////////////////////
//////////// CONTAINER

resource "azurerm_storage_container" "container" {
  depends_on = [azurerm_storage_account.sa]
  count      = length(var.containers)

  name                  = var.containers[count.index].name
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = var.containers[count.index].access_type

  #lifecycle {
  #ignore_changes = [name] # if "name" is ignored then new Containers won't be created 
  #}
}

///////////////////////////////////////////////////////////////////////
//////////// SHARE
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_share
resource "azurerm_storage_share" "share" {
  depends_on = [azurerm_storage_account.sa]
  count      = length(var.shares)

  name                 = var.shares[count.index].name
  storage_account_name = azurerm_storage_account.sa.name
  quota                = var.shares[count.index].quota #  (Optional) The maximum size of the share, in gigabytes. For Standard storage accounts, this must be greater than 0 and less than 5120 GB (5 TB). For Premium FileStorage storage accounts, this must be greater than 100 GB and less than 102400 GB (100 TB). Default is 5120.
  enabled_protocol     = "SMB"                         # (Optional) The protocol used for the share. Possible values are SMB and NFS. The SBM indicates the share can be accessed by SMBv3.0, SMBv2.1 and REST. The NFS indicates the share can be accessed by NFSv4.1. Defaults to SMB. Changing this forces a new resource to be created. The Premium sku of the azurerm_storage_account is required for the NFS protocol.
  #metadata = {} # (Optional) A mapping of MetaData for this File Share.

  acl {
    id = md5(var.shares[count.index].name) # (Required) The ID which should be used for this Shared Identifier.

    access_policy {
      permissions = var.shares[count.index].permissions #  rwdl, (Required) The permissions which should be associated with this Shared Identifier. Possible value is combination of r (read), w (write), d (delete), and l (list).
      #start       = "2019-07-02T09:38:21.0000000Z" # (Optional) The time at which this Access Policy should be valid from, in ISO8601 format.
      #expiry      = "2019-07-02T10:38:21.0000000Z" #  (Optional) The time at which this Access Policy should be valid until, in ISO8601 format.
    }
  }

  lifecycle {
    ignore_changes = [quota]
  }
}

///////////////////////////////////////////////////////////////////////
//////////// RBAC

resource "azurerm_role_assignment" "role" {
  depends_on = [azurerm_storage_account.sa]
  count      = var.enable_rbac_authorization ? length(var.rbac_roles) : 0

  scope                = azurerm_storage_account.sa.id
  role_definition_name = var.rbac_roles[count.index].role_definition_name
  principal_id         = var.rbac_roles[count.index].principal_id
}
