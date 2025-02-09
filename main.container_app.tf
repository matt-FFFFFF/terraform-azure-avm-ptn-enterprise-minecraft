
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
            name  = "OPS"
            value = "mattffffff"
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
