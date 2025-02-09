# This is the public IP address resource that will be used for the Azure Firewall.
module "firewall_public_ip" {
  source              = "Azure/avm-res-network-publicipaddress/azurerm"
  version             = "0.2.0"
  name                = "pip-fw-minecraft"
  location            = local.location
  resource_group_name = module.resource_group.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]
}


# This is the Azure Firewall resource that will be used to control the network traffic in the environment.
# Due to the route table configuration, the firewall will be the default gateway for the virtual network.
module "firewall" {
  source              = "Azure/avm-res-network-azurefirewall/azurerm"
  version             = "0.3.0"
  name                = "azfw-minecraft"
  location            = local.location
  resource_group_name = module.resource_group.name
  firewall_sku_tier   = "Standard"
  firewall_sku_name   = "AZFW_VNet"
  firewall_zones      = ["1", "2", "3"]
  firewall_policy_id  = module.firewall_policy.resource_id
  firewall_ip_configuration = [
    {
      name                 = "ipconfig1"
      subnet_id            = module.virtual_network.subnets["firewall"].resource_id
      public_ip_address_id = module.firewall_public_ip.resource_id
    }
  ]
}


# This is the firewall policy resource that we will assign to the Azure Firewall.
# It is used to define the DNS proxy settings and the diagnostic settings for the firewall.
# The firewall rules are defined in the rule collection groups.
module "firewall_policy" {
  source              = "Azure/avm-res-network-firewallpolicy/azurerm"
  version             = "0.3.3"
  name                = "fwp-minecraft"
  location            = local.location
  resource_group_name = module.resource_group.name
  firewall_policy_dns = {
    proxy_enabled = true
  }
  firewall_policy_insights = {
    enabled                            = true
    default_log_analytics_workspace_id = module.log_analytics.resource_id
    retention_in_days                  = 30
  }
}

# This is a dedicated rule collection group for outbound traffic from the Minecraft server and vnet in general.
# It must be created before the container app to ensure outbound traffic can reach the management plane.
module "firewall_policy_rule_collection_group" {
  source                                                   = "Azure/avm-res-network-firewallpolicy/azurerm//modules/rule_collection_groups"
  version                                                  = "0.3.2"
  firewall_policy_rule_collection_group_firewall_policy_id = module.firewall_policy.resource_id
  firewall_policy_rule_collection_group_name               = "rcg-minecraft"
  firewall_policy_rule_collection_group_priority           = 1000
  firewall_policy_rule_collection_group_application_rule_collection = [
    {
      action   = "Allow"
      name     = "vnet-outbound"
      priority = 300
      rule = [
        {
          name             = "vnet-outbound"
          source_addresses = ["192.168.0.0/16"]
          protocols = [
            {
              port = 443
              type = "Https"
            },
            {
              port = 80
              type = "Http"
            }
          ]
          destination_fqdns = ["*"]
        }
      ]
    }
  ]
  firewall_policy_rule_collection_group_nat_rule_collection = []
  firewall_policy_rule_collection_group_network_rule_collection = [
    {
      action   = "Allow"
      name     = "container-app-outbound"
      priority = 400
      rule = [
        {
          name = "nrc-containerapp-out"
          destination_addresses = [
            "MicrosoftContainerRegistry",
            "AzureFrontDoorFirstParty",
            "AzureContainerRegistry",
            "AzureActiveDirectory",
            "AzureKeyVault",
          ]
          protocols         = ["TCP", "UDP"]
          source_addresses  = ["192.168.4.0/23"]
          destination_ports = ["*"]
        }
      ]
    },
  ]
}

# This is a dedicated rule collection group for inbound traffic to the Minecraft server
# It is it is a separate resource to ensure there are no dependency issues when creating the rules.
# We cannot create this RCG until the load balancer IP is known for the container app environment.
module "firewall_policy_rule_collection_group_inbound" {
  source                                                   = "Azure/avm-res-network-firewallpolicy/azurerm//modules/rule_collection_groups"
  version                                                  = "0.3.2"
  firewall_policy_rule_collection_group_firewall_policy_id = module.firewall_policy.resource_id
  firewall_policy_rule_collection_group_name               = "rcg-minecraft-in"
  firewall_policy_rule_collection_group_priority           = 1100
  firewall_policy_rule_collection_group_nat_rule_collection = [
    {
      action   = "Dnat"
      name     = "nat-minecraft-server"
      priority = 100
      rule = [
        {
          destination_addresses = [module.firewall_public_ip.public_ip_address]
          destination_ports     = [tostring(local.minecraft_port)]
          name                  = "minecraft-server"
          protocols             = ["TCP"]
          source_addresses      = ["*"]
          destination_address   = module.firewall_public_ip.public_ip_address
          translated_address    = module.managed_environment.static_ip_address
          translated_port       = local.minecraft_port
        }
      ]
    }
  ]
  firewall_policy_rule_collection_group_network_rule_collection = [
    {
      action   = "Allow"
      name     = "minecraft-server-in"
      priority = 200
      rule = [
        {
          name                  = "nrc-minecraft-server-in"
          protocols             = ["TCP"]
          destination_addresses = [module.managed_environment.static_ip_address]
          source_addresses      = ["0.0.0.0/0"]
          destination_ports     = [local.minecraft_port]
        }
      ]
    },
  ]
}
