resource "random_id" "storage" {
  byte_length = 6
  prefix      = "stg"
}

data "http" "ipify" {
  url = "https://api4.ipify.org/"
}

module "storage" {
  source                    = "Azure/avm-res-storage-storageaccount/azurerm"
  version                   = "0.4.0"
  location                  = local.location
  resource_group_name       = module.resource_group.name
  name                      = random_id.storage.hex
  account_tier              = "Standard"
  account_replication_type  = "ZRS"
  shared_access_key_enabled = true
  shares = {
    minecraft = {
      name             = "minecraft"
      enabled_protocol = "SMB"
      access_tier      = "Hot"
      quota            = 5
    }
  }
  default_to_oauth_authentication = true
  public_network_access_enabled   = true

  network_rules = {
    bypass         = ["None"]
    default_action = "Deny"
    ip_rules       = [data.http.ipify.response_body]
  }

  # You need to configure the private endpoint for the storage account here!
  # Have a look at the Azure Verified Modules website (the interfaces specification) to see if you can work it out.
  private_endpoints = {}
}
