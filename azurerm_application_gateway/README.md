https://github.com/kumarvna/terraform-azurerm-application-gateway


`private_link_configuration`
The AllowApplicationGatewayPrivateLink feature must be registered on the subscription before enabling private link

##### PROBLEM

│ Error: creating/updating Application Gateway: (Name "*" / Resource Group "*"): network.ApplicationGatewaysClient#CreateOrUpdate: Failure sending request: StatusCode=400 -- Original Error: 
Code="InvalidResourceReference" Message="Resource /subscriptions/*/resourceGroups/*/providers/Microsoft.Network/applicationGateways/*/authenticationCertificates/* referenced by resource /subscriptions/*/resourceGroups/*/providers/Microsoft.Network/applicationGateways/*/backendHttpSettingsCollection/* was not found. Please make sure that the referenced resource exists, and that both resources are in the same region." Details=[]
│
│   with module.application_gateway[0].azurerm_application_gateway.agw,
│   on ..\..\..\modules\azurerm_application_gateway\resources.tf line 4, in resource "azurerm_application_gateway" "agw":
│    4: resource "azurerm_application_gateway" "agw" {

##### Solution

https://github.com/hashicorp/terraform-provider-azurerm/issues/5497

##### Problem

╷
│ Error: updating Application Gateway: (Name "*" / Resource Group "*"): network.ApplicationGatewaysClient#CreateOrUpdate: Failure sending request: StatusCode=400 -- Original Error: Code="ApplicationGatewayFirewallCannotBeEnabledForSelectedSku" Message="Application Gateway /subscriptions/*/resourceGroups/*/providers/Microsoft.Network/applicationGateways/* does not support WebApplicationFirewall with the selected SKU tier Standard_v2" Details=[]


Error: updating Application Gateway: (Name "*" / Resource Group "|"): network.ApplicationGatewaysClient#CreateOrUpdate: Failure sending request: StatusCode=400 -- Original Error: Code="ApplicationGatewaySkuNameInvalidForSkuTier" Message="Application Gateway SKU name Standard_v2 is not valid for the SKU tier WAF_v2" Details=[]

##### Solution

Changing from WAF_v2 to Standard_v2 on tier Tier and Sku must done in two steps, not at the same time. 1. Change the Tier=Standard, Sku=Standard_Small, then change back to Tier=Standard_v2, Sku=Standard_v2


