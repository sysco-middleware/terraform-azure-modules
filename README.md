# terraform-azure-modules
HashiCorp Terraform Azure modules 
### Versions
---

#### These are the supported versions: 

* Azure CLI: 2.36.0
* Terraform CLI: 1.1.9
* Tag version: v0.0.9
* Terraform Provider: hashicorp/azuread: 2.22.0
* Terraform Provider: hashicorp/azurerm: 3.7.0
* Terraform Provider: hashicorp/local: 2.2.2
* Terraform Provider: hashicorp/random: 3.1.0
* Terraform Provider: hashicorp/null: 3.1.0   

### Module usage
---


```
module "module_alias_name" {
  source     = "github.com/sysco-middleware/terraform-azure-modules.git/modulename"
  #source     = "github.com/sysco-middleware/terraform-azure-modules.git//modulename?ref=branchname"
  #source     = "github.com/sysco-middleware/terraform-azure-modules.git//modulename?ref=tagversion"

  ...
}
```