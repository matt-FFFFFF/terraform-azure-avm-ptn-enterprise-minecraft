module "virtual_network" {
  source              = "Azure/avm-res-network-virtualnetwork/azurerm"
  version             = "0.7.1"
  location            = local.location
  address_space       = ["192.168.0.0/16"]
  name                = "vnet-minecraft"
  resource_group_name = module.resource_group.name
  subnets = {
    firewall = {
      name             = "AzureFirewallSubnet"
      address_prefixes = ["192.168.0.0/24"]
      name             = "AzureFirewallSubnet"
    }
    app = {
      name                            = "app"
      address_prefixes                = ["192.168.4.0/23"]
      default_outbound_access_enabled = false
    }
    private_endpoint = {
      name                            = "private-endpoint"
      address_prefixes                = ["192.168.2.0/24"]
      default_outbound_access_enabled = false
    }
  }
  diagnostic_settings = {
    log_analytics = {
      workspace_resource_id = module.log_analytics.resource_id
      name                  = "log"
      log_groups            = ["allLogs"]
      metric_categories     = ["AllMetrics"]
    }
  }
}
