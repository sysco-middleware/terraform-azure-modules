https://github.com/kumarvna/terraform-azurerm-application-gateway


`private_link_configuration`
The AllowApplicationGatewayPrivateLink feature must be registered on the subscription before enabling private link

##### PROBLEM

│ Error: creating/updating Application Gateway: (Name "*" / Resource Group "*"): network.ApplicationGatewaysClient#CreateOrUpdate: Failure sending request: StatusCode=400 -- Original Error: 
Code="InvalidResourceReference" Message="Resource /subscriptions/c1f9772c-a272-477e-9a31-1870d24adf44/resourceGroups/*/providers/Microsoft.Network/applicationGateways/*/authenticationCertificates/* referenced by resource /subscriptions/c1f9772c-a272-477e-9a31-1870d24adf44/resourceGroups/*/providers/Microsoft.Network/applicationGateways/*/backendHttpSettingsCollection/* was not found. Please make sure that the referenced resource exists, and that both resources are in the same region." Details=[]
│
│   with module.application_gateway[0].azurerm_application_gateway.agw,
│   on ..\..\..\modules\azurerm_application_gateway\resources.tf line 4, in resource "azurerm_application_gateway" "agw":
│    4: resource "azurerm_application_gateway" "agw" {

##### Solution

https://github.com/hashicorp/terraform-provider-azurerm/issues/5497

