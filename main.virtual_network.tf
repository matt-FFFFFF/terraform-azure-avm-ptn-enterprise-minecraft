locals {
  firewall_subnet_cidr = "192.168.0.0/24"
  firewall_ip          = cidrhost(local.firewall_subnet_cidr, 4)
}

module "virtual_network" {
  source        = "Azure/avm-res-network-virtualnetwork/azurerm"
  version       = "0.8.1"
  location      = local.location
  address_space = ["192.168.0.0/16"]
  name          = "vnet-minecraft"
  dns_servers = {
    dns_servers = [local.firewall_ip]
  }
  resource_group_name = module.resource_group.name
  subnets = {
    firewall = {
      name             = "AzureFirewallSubnet"
      address_prefixes = [local.firewall_subnet_cidr]
      name             = "AzureFirewallSubnet"
    }
    app = {
      name                            = "app"
      address_prefixes                = ["192.168.4.0/23"]
      default_outbound_access_enabled = false
      route_table = {
        id = module.route_table.resource_id
      }
      delegation = [
        {
          name = "Microsoft.App/environments"
          service_delegation = {
            name = "Microsoft.App/environments"
          }
        }
      ]
    }
    private_endpoint = {
      name                                          = "private-endpoint"
      address_prefixes                              = ["192.168.2.0/24"]
      default_outbound_access_enabled               = false
      private_link_service_network_policies_enabled = true
      route_table = {
        id = module.route_table.resource_id
      }
    }
  }
}

module "route_table" {
  source              = "Azure/avm-res-network-routetable/azurerm"
  version             = "0.3.1"
  name                = "rt-tofirewall"
  resource_group_name = module.resource_group.name
  location            = local.location

  routes = {
    to-firewall = {
      name                   = "to-firewall"
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = local.firewall_ip
    },
  }
}
