locals {
  network_names = [
    "ext",
    "int",
    "hasync",
    "mgmt"
  ]

  cidrs1 = {
    ext = "172.20.0.0/25"
    int = "172.20.1.0/25"
    hasync = "172.20.2.0/25"
    mgmt = "172.20.3.0/25"
  }
  cidrs2 = {
    ext = "172.20.0.128/25"
    int = "172.20.1.128/25"
    hasync = "172.20.2.128/25"
    mgmt = "172.20.3.128/25"
  }
}

#prepare the networks
resource google_compute_network "demo" {
  for_each      = toset(local.network_names)

  name          = "bm-nccdemo-vpc-${each.value}"
  auto_create_subnetworks = false
}

resource google_compute_subnetwork "demo1" {
  for_each      = toset(local.network_names)

  name          = "bm-nccdemo-sb-${each.value}-${var.region_short1}"
  region        = var.region1
  network       = google_compute_network.demo[ each.value ].self_link
  ip_cidr_range = local.cidrs1[ each.value ]
}

resource google_compute_subnetwork "demo2" {
  for_each      = toset(local.network_names)

  name          = "bm-nccdemo-sb-${each.value}-${var.region_short2}"
  region        = var.region2
  network       = google_compute_network.demo[ each.value ].self_link
  ip_cidr_range = local.cidrs2[ each.value ]
}

# deploy the FortiGates
module "fgt_ha" {
  source        = "git::github.com/40net-cloud/fortigate-gcp-ha-ap-lb-terraform"

  prefix        = "bm-nccdemo-"
  region        = var.region1
  image_family  = "fortigate-72-byol"
  labels        = {
    owner : "bmoczulski"
    knock : "51845"
  }
  frontends     = ["pub"]
  subnets       = [ for key in local.network_names: google_compute_subnetwork.demo1[ key ].name ]
  routes        = {}
  flexvm_tokens = ["2E735A2BFD0C45D38D0E", "5F7EA40C12A44D6587AF" ]

  api_accprofile = "prof_admin"
  api_acl = ["209.198.137.129/32"]
  api_token_secret_name = "bm-nccdemo1"

  depends_on    = [
    google_compute_subnetwork.demo1
  ]
}

module "fgt_ha2" {
  source        = "git::github.com/40net-cloud/fortigate-gcp-ha-ap-lb-terraform"

  prefix        = "bm-nccdemo-"
  region        = var.region2
  image_family  = "fortigate-72-byol"
  labels        = {
    owner : "bmoczulski"
    knock : "51845"
  }
  frontends     = ["pub"]
  subnets       = [ for key in local.network_names: google_compute_subnetwork.demo2[ key ].name ]
  routes        = {}
  flexvm_tokens = ["08F6598CF10146588698", "A10A071FB28E4934AFAB" ]

  api_accprofile = "prof_admin"
  api_acl = ["209.198.137.129/32"]
  api_token_secret_name = "bm-nccdemo2"

  depends_on    = [
    google_compute_subnetwork.demo2
  ]
}

output outputs {
  value = module.fgt_ha
}
