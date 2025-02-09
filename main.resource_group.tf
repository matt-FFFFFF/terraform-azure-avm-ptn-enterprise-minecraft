# The resource group
module "resource_group" {
  source   = "Azure/avm-res-resources-resourcegroup/azurerm"
  version  = "0.2.0"
  location = local.location
  name     = local.resource_group_name
}
