resource "fortios_router_bgp" "fgt1" {
  as = var.fgt_asn
  ebgp_multipath = "enable"
  graceful_restart = "enable"

  neighbor {
    ip = google_compute_address.cr_nic0.address
    capability_graceful_restart = "enable"
    ebgp_enforce_multihop = "enable"
    soft_reconfiguration = "enable"
    interface = "port2"
    capability_default_originate = "enable"
    remote_as = var.ncc_asn
  }
  neighbor {
    ip = google_compute_address.cr_nic1.address
    capability_graceful_restart = "enable"
    ebgp_enforce_multihop = "enable"
    soft_reconfiguration = "enable"
    interface = "port2"
    capability_default_originate = "enable"
    remote_as = var.ncc_asn
  }

}
