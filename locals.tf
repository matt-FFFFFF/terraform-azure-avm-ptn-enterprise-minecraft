locals {
  minecraft_port = 25565
  locations = [
    "swedencentral",
    "uksouth",
    "francecentral",
    "japaneast",
    "canadacentral",
    "centralus",
  ]
  location = local.locations[random_integer.region_index.result]
}
