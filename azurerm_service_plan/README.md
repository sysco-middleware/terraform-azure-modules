## azurerm_app_service_plan

### Module resources
---

* https://docs.microsoft.com/en-us/azure/azure-functions/functions-premium-plan?tabs=azurecli#features


### Module info
---

* `sku_name`Isolated SKUs (I1, I2, I3, I1v2, I2v2, and I3v2) can only be used with App Service Environments. Elastic and Consumption SKUs (Y1, EP1, EP2, and EP3) are for use with Function Apps
* `kind` Can't configure a value for "kind": its value will be decided automatically based on the result of applying this configuration.
* `reserved`  Can't configure a value for "reserved": its value will be decided automatically based on the result of applying this configuration.
* `` https://docs.microsoft.com/en-us/azure/app-service/how-to-zone-redundancy
### Module usage
---

```
locals {
    environment  = terraform.workspace
    rg_name = "__ENTER_VALUE__"
    re_tags = {
        created_by   = "FirstName LastName"
        created_date = formatdate("YYYY-MM-DD hh:mm:ss ZZZ", timestamp())
        environment  = local.environment
        managed_by   = "Terraform"
    }
    
    asp_name = "__ENTER_VALUE__"
    sku = {
        sp_kind     = "StorageV2"
        sp_tier     = "Standard"
        sp_name     = "S0"
        asp_capacity = 1
    }
        
}

module "resource_group" {
  source     = "github.com/sysco-middleware/terraform-azure-modules.git//azurerm_resource_group"

  ...
}

module "service_plan" {
  source     = "github.com/sysco-middleware/terraform-azure-modules.git//azurerm_service_plan"
  depends_on = [module.resource_group]

  name             = local.sp_name
  rg_name          = local.rg_name
  os_type          = "Windows"
  kind             = null
  sku_name         = "B1"
  tags             = local.re_tags
}


```

### Module troubleshoot
---

