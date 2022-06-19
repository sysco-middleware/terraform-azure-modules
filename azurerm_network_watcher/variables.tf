variable "name" {}
variable "rg_name" {}
variable "location" {
  type        = string
  description = "Network Watcher is regianal based. https://docs.microsoft.com/en-us/azure/network-watcher/network-watcher-create#create-a-network-watcher-in-the-portal"
  default     = "westeurope"
}
variable "tags" {
  type        = map(any)
  description = "A mapping of tags to assign to the resource."
  default     = {}
}
