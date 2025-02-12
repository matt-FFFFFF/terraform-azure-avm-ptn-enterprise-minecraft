locals {
  minecraft_port = 25565

  # The module will randomly select a location from the list below
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
