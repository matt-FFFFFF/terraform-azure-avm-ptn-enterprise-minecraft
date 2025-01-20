module "private_dns_zone" {
  source              = "Azure/avm-res-network-privatednszone/azurerm"
  version             = "0.2.2"
  resource_group_name = module.resource_group.name
  domain_name         = "privatelink.file.core.windows.net"
}
