
### Module info

* os_disk.disk_encryption_set_id: https://docs.microsoft.com/en-us/azure/virtual-machines/windows/disk-encryption-overview
* `encryption_at_host_enabled` https://docs.microsoft.com/en-us/azure/virtual-machines/linux/disks-enable-host-based-encryption-cli
  az feature register --namespace Microsoft.Compute --name EncryptionAtHost --subscription __Enter__
   az provider register -n Microsoft.Compute --subscription __Enter__


### Module troubleshoot
---

#### Problem-1

```
Error: creating Windows Virtual Machine: (Name "*" / Resource Group "*"): compute.VirtualMachinesClient#CreateOrUpdate: Failure sending request: StatusCode=400 -- Original Error: Code="InvalidParameter" Message="The property 'securityProfile.encryptionAtHost' is not valid because the 'Microsoft.Compute/EncryptionAtHost' feature is not enabled for this subscription." Target="securityProfile.encryptionAtHost"
│
│   with module.windows_virtual_machine.azurerm_windows_virtual_machine.wvm,
│   on C:\Users\*\.terraform\*\windows_virtual_machine\azurerm_windows_virtual_machine\resources.tf line 27, in resource "azurerm_windows_virtual_machine" "wvm":
│   27: resource "azurerm_windows_virtual_machine" "wvm" {
```

#### Solution-1

https://docs.microsoft.com/en-us/azure/virtual-machines/linux/disks-enable-host-based-encryption-cli

```powershell
az feature show --namespace Microsoft.Compute --name EncryptionAtHost --subscription *

az feature register --namespace Microsoft.Compute --name EncryptionAtHost --subscription *

# Once the feature 'EncryptionAtHost' is registered, invoking 'az provider register -n Microsoft.Compute' is required to get the change propagated
```