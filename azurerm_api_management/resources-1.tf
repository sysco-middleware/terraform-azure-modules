resource "random_uuid" "uuid" {}
resource "azurerm_api_management" "apim" {
  depends_on = [data.azurerm_resource_group.rg]

  name                = var.name
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  publisher_name      = var.publisher_name
  publisher_email     = var.publisher_email

  sku_name = var.sku_name
  /* Only supported for Premium or Developer
  additional_location {
    location = "westeurope" #  (Required) The name of the Azure Region in which the API Management Service should be expanded to.
    # (Optional) A virtual_network_configuration block as defined below. Required when virtual_network_type is External or Internal
    virtual_network_configuration {
      subnet_id = ""
    }
  }
  */
  gateway_disabled = false #  Disable the gateway in main region? This is only supported when additional_location is set
  #min_api_version = "" # The version which the control plane API calls to API Management service are limited with version equal to or newer than.

  identity {
    type = "SystemAssigned" # System Assigned which is required to access KeyVault when custom domain is activated 
  }
  /*
  hostname_configuration {
    management {
      host_name = ""
    }
    portal {
      host_name = ""
    }
    developer_portal {
      host_name = ""
    }
    #proxy {}
    scm {
      host_name = ""
    }
  }
  */
  notification_sender_email = ""
  policy {
    xml_content = var.all_apis_policy
  }
  protocols {

  }
  sign_in {
    enabled = true
  }
  sign_up {
    enabled = true
    terms_of_service {
      enabled          = true
      consent_required = false
    }
  }
  tenant_access {
    enabled = true
  }
  virtual_network_type = "None" # Please ensure that in the subnet, inbound port 3443 is open when virtual_network_type is Internal or External

  tags = var.tags

  lifecycle {
    ignore_changes = [tags, location]
  }
}

resource "azurerm_api_management_user" "user" {
  depends_on = [azurerm_api_management.apim]
  count      = length(var.users)

  user_id             = uuid() #random_uuid.uuid.result
  api_management_name = azurerm_api_management.apim.name
  resource_group_name = data.azurerm_resource_group.rg.name
  first_name          = var.users[count.index].firstname
  last_name           = var.users[count.index].lastname
  email               = var.users[count.index].email
  password            = "_${title(var.users[count.index].lastname)}"
  state               = "active"

  lifecycle {
    ignore_changes = [user_id]
  }
}

resource "azurerm_api_management_group" "group" {
  depends_on = [azurerm_api_management.apim]
  count      = length(var.groups)

  name                = var.groups[count.index].name
  resource_group_name = data.azurerm_resource_group.rg.name
  api_management_name = azurerm_api_management.apim.name
  display_name        = var.groups[count.index].display_name
  description         = var.groups[count.index].description
}


resource "azurerm_management_lock" "law_lock" {
  depends_on = [azurerm_api_management.apim]
  count      = var.lock_resource ? 1 : 0

  name       = "CanNotDelete"
  scope      = azurerm_api_management.apim.id
  lock_level = "CanNotDelete"
  notes      = "Terraform: This prevents accidental deletion of this resource."

  lifecycle {
    ignore_changes = [name, notes]
  }
}
