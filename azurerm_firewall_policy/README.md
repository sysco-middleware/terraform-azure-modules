### Module info
---


* 
`private_ip_ranges` 

https://docs.microsoft.com/en-us/azure/firewall/snat-private-range
https://docs.microsoft.com/en-us/azure/firewall/snat-private-range#firewall-policy

Use the subnet range (local IP ranges, such as 10.*.*.*/*, etc ) used by your frontend or DMZ service (function app, web app, kubernetes egress etc)   

`sku_tier`

https://docs.microsoft.com/en-us/azure/firewall/premium-features
Intrusion, certificate and threat properties are only supported by Premium sku
https://docs.microsoft.com/en-us/azure/firewall/premium-features

`key_vault_secret_id` Create a certificate in 
### Notes
---



### ERROR

 Error: expected "private_ip_ranges.0" to be a valid IPv4 Value, got IANAPrivateRanges: invalid CIDR address: IANAPrivateRanges
│
│   with module.firewall_policy.azurerm_firewall_policy.policy,
│   on C:\Users\100wow\.terraform\*\network\modules\firewall_policy\azurerm_firewall_policy\resources.tf line 8, in resource "azurerm_firewall_policy" "policy":
│    8:   private_ip_ranges        = local.private_ip_ranges
│