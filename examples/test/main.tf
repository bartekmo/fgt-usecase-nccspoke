terraform {
  required_version = ">= 1.0.1"
  required_providers {
    google = {
      source = "hashicorp/google"
    }
    fortios = {
      source = "fortinetdev/fortios"
    }
  }
}

data "google_secret_manager_secret_version" "token" {
  secret = "bm-nccdemo1"
}

data "google_compute_instance" "fgts" {
  for_each = toset(var.fgt_self_links)
  self_link = each.value
}

provider "fortios" {
  alias = "fgt1"
  hostname = reverse(data.google_compute_instance.fgts[var.fgt_self_links[0]].network_interface)[0].access_config[0].nat_ip
  token = data.google_secret_manager_secret_version.token.secret_data
  insecure = "true"
}
provider "fortios" {
  alias = "fgt2"
  hostname = reverse(data.google_compute_instance.fgts[var.fgt_self_links[1]].network_interface)[0].access_config[0].nat_ip
  token = data.google_secret_manager_secret_version.token.secret_data
  insecure = "true"
}

data "fortios_json_generic_api" "ha_checksums1" {
  provider = fortios.fgt1
  path = "/api/v2/monitor/system/ha-checksums"
}
data "fortios_json_generic_api" "ha_checksums2" {
  provider = fortios.fgt2
  path = "/api/v2/monitor/system/ha-checksums"
}

locals {
  fgt_checksum_data = jsondecode(data.fortios_json_generic_api.ha_checksums1.response)
  master_serial = [ for fgt in local.fgt_checksum_data.results : fgt.serial_no if fgt.is_root_primary ][0]
  fgt_serials = [
    jsondecode(data.fortios_json_generic_api.ha_checksums1.response).serial,
    jsondecode(data.fortios_json_generic_api.ha_checksums2.response).serial
  ]
}

output "test" {
  value = local.fgt_serials
}
