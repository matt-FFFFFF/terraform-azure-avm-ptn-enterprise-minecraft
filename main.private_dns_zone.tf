locals {
  private_dns_zones = {
    storage = {
      domain_name = "privatelink.file.core.windows.net"
    }
  }
}

module "private_dns_zone" {
  for_each            = local.private_dns_zones
  source              = "Azure/avm-res-network-privatednszone/azurerm"
  version             = "0.2.2"
  resource_group_name = module.resource_group.name
  domain_name         = each.value.domain_name
  virtual_network_links = {
    minecraft = {
      vnetid       = module.virtual_network.resource_id
      vnetlinkname = "vnl-minecraft"
    }
  }
}
