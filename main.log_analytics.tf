resource "random_id" "log_analytics" {
  byte_length = 6
  prefix      = "law"
}

module "log_analytics" {
  source                                         = "Azure/avm-res-operationalinsights-workspace/azurerm"
  version                                        = "0.4.2"
  name                                           = random_id.log_analytics.hex
  location                                       = local.location
  resource_group_name                            = module.resource_group.name
  log_analytics_workspace_retention_in_days      = 30
  log_analytics_workspace_sku                    = "PerGB2018"
  log_analytics_workspace_internet_query_enabled = true
  log_analytics_workspace_identity = {
    type = "SystemAssigned"
  }
  monitor_private_link_scope = {
    pe1 = {
      name        = "law-pe1-scope"
      resource_id = module.resource_group.resource_id
    }
  }
  monitor_private_link_scoped_service_name = "law-pl-service"
  private_endpoints = {
    pe1 = {
      subnet_resource_id          = module.virtual_network.subnets["private_endpoint"].resource_id
      network_interface_name      = "nic-law-pe-service"
      private_dns-zone_group_name = "zg-law-pe-service"
    }
  }
}
