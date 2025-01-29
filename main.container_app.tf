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
  workload_profile = [{
    maximum_count         = 1
    minimum_count         = 1
    name                  = "minecraft"
    workload_profile_type = "D4"
  }]
  depends_on = [module.firewall]
}

module "container_app" {
  source                                = "Azure/avm-res-app-containerapp/azurerm"
  version                               = "0.3.0"
  container_app_environment_resource_id = module.managed_environment.resource_id
  name                                  = "minecraft-server"
  resource_group_name                   = module.resource_group.name
  revision_mode                         = "Single"
  workload_profile_name                 = "minecraft"
  tags                                  = {}

  template = {
    max_replicas = 1
    containers = [
      {
        name   = "minecraft-server"
        memory = "4Gi"
        cpu    = 2.00
        image  = "docker.io/itzg/minecraft-server:2025.1.0"
        env = [
          {
            name  = "EULA"
            value = "true"
          },
          {
            name  = "MEMORY"
            value = "3G"
          },
          {
            name  = "VERSION"
            value = "1.21.4"
          },
          {
            name  = "VIEW_DISTANCE"
            value = "16"
          }
        ]
        volume_mounts = [
          {
            name = "minecraft-data"
            path = "/data"
          }
        ]
      },
    ]
    volumes = [
      {
        name         = "minecraft-data"
        storage_name = "minecraft"
        storage_type = "AzureFile"
      }
    ]
  }
  ingress = {
    external_enabled = true
    exposed_port     = local.minecraft_port
    target_port      = local.minecraft_port
    transport        = "tcp"
    traffic_weight = [{
      latest_revision = true
      percentage      = 100
    }]
  }
}
