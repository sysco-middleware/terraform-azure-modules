locals {
  # https://docs.microsoft.com/en-us/azure/firewall/snat-private-range#firewall-policy

  rules = {
    Never       = "0.0.0.0/0"          # Never route/SNAT traffic directly to the Internet
    Aways       = "255.255.255.255/32" #  Always route/SNAT regardless of the destination address
    UseIPRanges = var.snat_ip_ranges
  }
  snat_ip_ranges = local.rules[local.snat_rules]

}