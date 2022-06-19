https://github.com/kumarvna/terraform-azurerm-application-gateway


`private_link_configuration`
The AllowApplicationGatewayPrivateLink feature must be registered on the subscription before enabling private link


#### Vulnerabbility 
https://msrc-blog.microsoft.com/2021/12/11/microsofts-response-to-cve-2021-44228-apache-log4j2/#Azure-App-Service-(Windows-and-Linux)

##### PROBLEM

https://docs.microsoft.com/en-us/azure/application-gateway/configuration-infrastructure#supported-user-defined-routes

##### SOLUTION

https://github.com/hashicorp/terraform-provider-azurerm/issues/5497

##### PROBLEM 2 Installing with SSL 

az network application-gateway stop ..
(InternalServerError) An error occurred.
Code: InternalServerError
Message: An error occurred.
Command ran in 11.866 seconds (init: 0.089, invoke: 11.777)
PS /mnt/c/Users/100wow/OneDrive - Cegal AS/Dokumenter/Git/nog>
az network application-gateway start ..
(InternalServerError) An error occurred.
Code: InternalServerError
Message: An error occurred.

##### SOLUTION 2

This is a major bug cause by configuring a PFX certificate with password in that is automatically fetch from Keyvault 
According to installation only ssl_certificates.kv_sercret_id is needed, not password, but this happens to be incorrect.
The installation stops with Failed status. 

This same error also happends in the Application Gateway installation Wizard in the Portal.
The way I solveed this was to choose upload certficate and enter password. This shows that password is needed.

https://docs.microsoft.com/en-us/azure/application-gateway/key-vault-certs?WT.mc_id=Portal-Microsoft_Azure_Support#how-integration-works

##### Problem

╷
│ Error: updating Application Gateway: (Name "*" / Resource Group "*"): network.ApplicationGatewaysClient#CreateOrUpdate: Failure sending request: StatusCode=400 -- Original Error: Code="ApplicationGatewayFirewallCannotBeEnabledForSelectedSku" Message="Application Gateway /subscriptions/*/resourceGroups/*/providers/Microsoft.Network/applicationGateways/* does not support WebApplicationFirewall with the selected SKU tier Standard_v2" Details=[]


Error: updating Application Gateway: (Name "*" / Resource Group "|"): network.ApplicationGatewaysClient#CreateOrUpdate: Failure sending request: StatusCode=400 -- Original Error: Code="ApplicationGatewaySkuNameInvalidForSkuTier" Message="Application Gateway SKU name Standard_v2 is not valid for the SKU tier WAF_v2" Details=[]

##### Solution

Changing from WAF_v2 to Standard_v2 on tier Tier and Sku must done in two steps, not at the same time. 1. Change the Tier=Standard, Sku=Standard_Small, then change back to Tier=Standard_v2, Sku=Standard_v2

