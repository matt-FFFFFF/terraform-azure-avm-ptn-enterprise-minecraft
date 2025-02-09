resource "random_id" "log_analytics" {
  byte_length = 6
  prefix      = "law"
}

# Here we define our log analytics workspace.
# This workspace is used to store the logs from the Minecraft server and the Azure Firewall.
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
}
