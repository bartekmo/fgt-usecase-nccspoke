data "google_compute_instance" "fgts" {
  for_each = toset(var.fgt_self_links)
  self_link = each.value
}

data "google_compute_subnetwork" "int" {
  region = local.region
  name = reverse(split( "/", data.google_compute_instance.fgts[var.fgt_self_links[0]].network_interface.1.subnetwork))[0]
}

locals {
  region = regex("zones/(.*)-[abcdef]/instances", var.fgt_self_links[0])[0]
  region_short = replace( replace( replace( replace(local.region, "europe-", "eu"), "australia", "au" ), "northamerica", "na"), "southamerica", "sa")
}
