
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_namespace
resource "azurerm_servicebus_namespace" "sbns" {
  depends_on = [data.azurerm_resource_group.rg]

  name                = var.name
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  sku                 = var.sku
  capacity            = local.capacity
  zone_redundant      = local.zone_redundant
  local_auth_enabled  = var.local_auth_enabled
  tags                = var.tags

  # TODO:  customer_managed_key block supports the following:

  dynamic "identity" {
    for_each = var.managed_identity_type != null ? [1] : []
    content {
      type         = var.managed_identity_type
      identity_ids = local.identity_ids
    }
  }

  lifecycle {
    ignore_changes = [tags, location, sku] # IMPORTANT! Do do remove 'location' or else Terraform will want todo a forces replacement on the service bus 
  }
}

###########################################################
####### SERVICE BUS TOPICS

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_topic
resource "azurerm_servicebus_topic" "topic" {
  depends_on = [azurerm_servicebus_namespace.sbns]
  count      = length(var.topics)

  name = var.topics[count.index].name
  #resource_group_name = data.azurerm_resource_group.rg.name  # Deprecated
  namespace_id = azurerm_servicebus_namespace.sbns.id

  lifecycle {
    ignore_changes = [namespace_id]
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_subscription
resource "azurerm_servicebus_subscription" "sub" {
  depends_on = [azurerm_servicebus_topic.topic]
  count      = length(var.topics)

  name = var.topics[count.index].subscriptions[0].name # TODO
  #resource_group_name = data.azurerm_resource_group.rg.name
  topic_id = azurerm_servicebus_topic.topic[count.index].id
  #namespace_name     = azurerm_servicebus_namespace.sbns.name
  #topic_name         = var.topics[count.index].name
  max_delivery_count = var.topics[count.index].subscriptions[0].max_count # TODO 

  lifecycle {
    ignore_changes = [topic_id]
  }
}


###########################################################
####### SERVICE BUS QUEUES

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_queue
resource "azurerm_servicebus_queue" "queue" {
  depends_on = [azurerm_servicebus_namespace.sbns, data.azurerm_resource_group.rg]
  count      = length(var.queues)

  name                  = var.queues[count.index].name
  namespace_id          = azurerm_servicebus_namespace.sbns.id
  lock_duration         = var.queues[count.index].lock_duration
  max_size_in_megabytes = var.queues[count.index].max_size_in_mb
  enable_partitioning   = local.enable_partitioning # (Optional) Boolean flag which controls whether to enable the queue to be partitioned across multiple message brokers. Changing this forces a new resource to be created. Defaults to false for Basic and Standard. For Premium, it MUST be set to true.
  #forward_to # (Optional) The name of a Queue or Topic to automatically forward messages to. Please see the documentation for more information.
  # forward_dead_lettered_messages_to - (Optional) The name of a Queue or Topic to automatically forward dead lettered messages to.

  lifecycle {
    ignore_changes = [namespace_id]
  }
}

###########################################################
####### ACCESS RULES

resource "azurerm_servicebus_namespace_authorization_rule" "rule_listen" {
  depends_on = [azurerm_servicebus_namespace.sbns, data.azurerm_resource_group.rg]

  name         = "Listen"
  namespace_id = azurerm_servicebus_namespace.sbns.id
  listen       = true
  send         = false
  manage       = false

  lifecycle {
    ignore_changes = [namespace_id]
  }
}

resource "azurerm_servicebus_namespace_authorization_rule" "rule_send" {
  depends_on = [azurerm_servicebus_namespace.sbns, data.azurerm_resource_group.rg]

  name         = "Send"
  namespace_id = azurerm_servicebus_namespace.sbns.id
  listen       = false
  send         = true
  manage       = false

  lifecycle {
    ignore_changes = [namespace_id]
  }
}

resource "azurerm_servicebus_queue_authorization_rule" "rule_listen" {
  depends_on = [azurerm_servicebus_queue.queue]
  count      = length(var.queues)

  name     = "Listen"
  queue_id = azurerm_servicebus_queue.queue[count.index].id
  listen   = true
  send     = false
  manage   = false

  lifecycle {
    ignore_changes = [queue_id]
  }
}

resource "azurerm_servicebus_queue_authorization_rule" "rule_send" {
  depends_on = [azurerm_servicebus_queue.queue]
  count      = length(var.queues)

  name     = "Send"
  queue_id = azurerm_servicebus_queue.queue[count.index].id
  send     = true
  listen   = false
  manage   = false

  lifecycle {
    ignore_changes = [queue_id]
  }
}

resource "azurerm_servicebus_queue_authorization_rule" "rule_manage" {
  depends_on = [azurerm_servicebus_queue.queue]
  count      = length(var.queues)

  name     = "Manage"
  queue_id = azurerm_servicebus_queue.queue[count.index].id
  manage   = true
  listen   = true
  send     = true

  lifecycle {
    ignore_changes = [queue_id]
  }
}

///////////////////////////////////////////////////////////////////////
//////////// RBAC
resource "azurerm_role_assignment" "sbns_role" {
  depends_on = [azurerm_servicebus_namespace.sbns]
  count      = var.enable_rbac_authorization ? length(var.rbac_roles) : 0

  scope                = azurerm_servicebus_namespace.sbns.id
  role_definition_name = var.rbac_roles[count.index].role_definition_name
  principal_id         = var.rbac_roles[count.index].principal_id

  lifecycle {
    ignore_changes = [scope]
  }
}

resource "azurerm_management_lock" "sbns_lock" {
  depends_on = [azurerm_servicebus_namespace.sbns]
  count      = var.lock_resource ? 1 : 0

  name       = "CanNotDelete"
  scope      = azurerm_servicebus_namespace.sbns.id
  lock_level = "CanNotDelete"
  notes      = "Terraform: This prevents accidental deletion of this resource."
}
