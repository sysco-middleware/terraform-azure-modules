# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet
resource "azurerm_subnet" "snet" {
  depends_on = [data.azurerm_virtual_network.vnet]
  for_each   = var.subnets
  iterator   = each

  name                                           = each.name
  resource_group_name                            = data.azurerm_resource_group.rg.name
  virtual_network_name                           = data.azurerm_virtual_network.vnet.name
  address_prefixes                               = each.cidr
  enforce_private_link_service_network_policies  = var.enforce_private_link_service_network_policies
  enforce_private_link_endpoint_network_policies = var.enforce_private_link_endpoint_network_policies
  service_endpoints                              = each.endpoints
  service_endpoint_policy_ids                    = var.service_endpoint_policy_ids

  # Designate a subnet to be used by a dedicated service.
  # Delegating to services may not be available in all regions. Check that the service you are delegating to is available in your region using the Azure CLI. 
  # Must use Dynamic block since only one service delegation is allowed
  dynamic "delegation" {
    for_each = toset(var.subnets[count.index].delegation) # Note: Only one Deligation is supported per subnet
    iterator = eachsub
    content {
      # Note: Microsoft.ContainerInstance/containerGroups cannot coexist with  Microsoft.Sql/servers 
      name = lower(replace(replace(eachsub.key, "Microsoft.", ""), "/", "_"))
      service_delegation {
        name = eachsub.key
        # Actions is specific to each service type. The exact list of actions needs to be retrieved using the aforementioned Azure CLI.
        actions = var.delegation_actions
      }
    }
  }

  lifecycle {
    ignore_changes = [name, service_endpoints]
  }
}
