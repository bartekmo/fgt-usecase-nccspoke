
resource "google_compute_address" "cr_nic0" {
  name          = "${var.prefix}-addr-cr-nic0"
  address_type  = "INTERNAL"
  subnetwork    = data.google_compute_subnetwork.int.self_link
  region        = local.region
}

resource "google_compute_address" "cr_nic1" {
  name          = "${var.prefix}-addr-cr-nic1"
  address_type  = "INTERNAL"
  subnetwork    = data.google_compute_subnetwork.int.self_link
  region        = local.region
}

resource "google_compute_router" "this" {
  name          = "${var.prefix}-cr-${local.region_short}"
  network       = data.google_compute_subnetwork.int.network
  region        = local.region
  bgp {
    asn               = var.ncc_asn
    advertise_mode    = "CUSTOM"
    advertised_groups = [
      "ALL_SUBNETS"
    ]
  }
}

resource "google_network_connectivity_spoke" "this" {
  name          = "${var.prefix}-spoke-${local.region_short}"
  location      = local.region
  hub           = var.ncc_hub_uri

  linked_router_appliance_instances {
    dynamic "instances" {
      for_each                 = data.google_compute_instance.fgts
      content {
        virtual_machine        = instances.key
        ip_address             = instances.value.network_interface[1].network_ip
      }
    }
    site_to_site_data_transfer = false
  }
}

resource "google_compute_router_interface" "cr_nic0" {
  name = "nic0"
  router = google_compute_router.this.name
  region = local.region
  subnetwork = data.google_compute_subnetwork.int.self_link
  private_ip_address = google_compute_address.cr_nic0.address
}

resource "google_compute_router_interface" "cr_nic1" {
  name = "nic1"
  router = google_compute_router.this.name
  region = local.region
  subnetwork = data.google_compute_subnetwork.int.self_link
  private_ip_address = google_compute_address.cr_nic1.address
  redundant_interface = google_compute_router_interface.cr_nic0.name
}

resource "google_compute_router_peer" "nic0_fgt1" {
  name                      = "nic0-fgt1"
  router                    = google_compute_router.this.name
  region                    = google_compute_router.this.region
  interface                 = google_compute_router_interface.cr_nic0.name
  peer_ip_address           = values(data.google_compute_instance.fgts)[0].network_interface[1].network_ip
  peer_asn                  = var.fgt_asn
  router_appliance_instance = values(data.google_compute_instance.fgts)[0].self_link
}
resource "google_compute_router_peer" "nic0_fgt2" {
  name                      = "nic0-fgt2"
  router                    = google_compute_router.this.name
  region                    = google_compute_router.this.region
  interface                 = google_compute_router_interface.cr_nic0.name
  peer_ip_address           = values(data.google_compute_instance.fgts)[1].network_interface[1].network_ip
  peer_asn                  = var.fgt_asn
  router_appliance_instance = values(data.google_compute_instance.fgts)[1].self_link
}
resource "google_compute_router_peer" "nic1_fgt1" {
  name                      = "nic1-fgt1"
  router                    = google_compute_router.this.name
  region                    = google_compute_router.this.region
  interface                 = google_compute_router_interface.cr_nic1.name
  peer_ip_address           = values(data.google_compute_instance.fgts)[0].network_interface[1].network_ip
  peer_asn                  = var.fgt_asn
  router_appliance_instance = values(data.google_compute_instance.fgts)[0].self_link
}
resource "google_compute_router_peer" "nic1_fgt2" {
  name                      = "nic1-fgt2"
  router                    = google_compute_router.this.name
  region                    = google_compute_router.this.region
  interface                 = google_compute_router_interface.cr_nic1.name
  peer_ip_address           = values(data.google_compute_instance.fgts)[1].network_interface[1].network_ip
  peer_asn                  = var.fgt_asn
  router_appliance_instance = values(data.google_compute_instance.fgts)[1].self_link
}
