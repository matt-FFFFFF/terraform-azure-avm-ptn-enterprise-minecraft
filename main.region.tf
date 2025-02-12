resource "random_integer" "region_index" {
  min = 0
  max = length(local.locations) - 1
}
