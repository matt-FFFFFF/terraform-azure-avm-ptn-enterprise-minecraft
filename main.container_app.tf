resource "random_id" "managed_environment" {
  byte_length = 6
  prefix      = "cae"
}

module "managed_environment" {
  source              = "Azure/avm-res-app-managedenvironment/azurerm"
  version             = "0.2.0"
  name                = random_id.managed_environment.hex
  resource_group_name = module.resource_group.name
  location            = local.location

  infrastructure_subnet_id                   = module.virtual_network.subnets["app"].resource_id
  infrastructure_resource_group_name         = "rg-managed-${random_id.managed_environment.id}"
  log_analytics_workspace_primary_shared_key = module.log_analytics.resource.primary_shared_key
  log_analytics_workspace_customer_id        = module.log_analytics.resource.workspace_id
  internal_load_balancer_enabled             = true
  storages = {
    minecraft = {
      account_name = module.storage.name
      share_name   = basename(module.storage.shares["minecraft"].id)
      access_key   = module.storage.resource.primary_access_key
      access_mode  = "ReadWrite"
    }
  }
}
