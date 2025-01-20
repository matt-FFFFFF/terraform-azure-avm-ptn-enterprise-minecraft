module "firewall_public_ip" {
  source  = "Azure/avm-res-network-publicipaddress/azurerm"
  version = "0.2.0"
  # insert the 3 required variables here
  name                = "pip-fw-minecraft"
  location            = local.location
  resource_group_name = module.resource_group.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]
}

module "firewall_policy" {
  source              = "Azure/avm-res-network-firewallpolicy/azurerm"
  version             = "0.3.2"
  name                = "fwp-minecraft"
  location            = local.location
  resource_group_name = module.resource_group.name
}

module "firewall" {
  source              = "Azure/avm-res-network-azurefirewall/azurerm"
  version             = "0.3.0"
  name                = "azfw-minecraft"
  location            = local.location
  resource_group_name = module.resource_group.name
  firewall_sku_tier   = "Standard"
  firewall_sku_name   = "AZFW_VNet"
  firewall_zones      = ["1", "2", "3"]
  firewall_ip_configuration = [
    {
      name                 = "ipconfig1"
      subnet_id            = module.virtual_network.subnets["firewall"].resource_id
      public_ip_address_id = module.firewall_public_ip.resource_id
    }
  ]
}

# module "firewall_policy_rule_collection_group" {
#   source                                                   = "Azure/avm-res-network-firewallpolicy/azurerm//modules/rule_collection_groups"
#   version                                                  = "0.3.2"
#   firewall_policy_rule_collection_group_firewall_policy_id = module.firewall_policy.resource_id
#   firewall_policy_rule_collection_group_name               = "rcg-minecraft"
#   firewall_policy_rule_collection_group_priority           = 1000
#   firewall_policy_rule_collection_group_nat_rule_collection = [
#     {
#       action   = "Dnat"
#       name     = "nat-minecraft-server"
#       priority = 100
#       rule = [
#         {
#           destination_addresses = [module.firewall_policy_public_ip.public_ip_address]
#           destination_ports     = [tostring(local.minecraft_port)]
#           name                  = "minecraft-server"
#           protocols             = ["TCP"]
#           source_addresses      = ["0.0.0.0/0"]
#           translated_address    = "TODO IP OF CONTAINER"
#           translated_port       = local.minecraft_port
#         }
#       ]
#     }
#   ]
#   firewall_policy_rule_collection_group_network_rule_collection = [
#     {
#       destination_ports = ["80", "443"]
#       name             = "minecraft-server-out"
#       protocols        = ["TCP"]
#       destination_addresses = ["0.0.0.0/0"]
#       source_addresses      = ["TODO IP OF CONTAINER"]
#     },
#     {
#       destination_ports = [local.minecraft_port]
#       name             = "minecraft-server-in"
#       protocols        = ["TCP", "UDP"]
#       destination_addresses = [module.firewall_policy_public_ip.public_ip_address]
#       source_addresses      = ["0.0.0.0/0"]
#     }
#   ]
# }
