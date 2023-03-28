data "google_secret_manager_secret_version" "token" {
  secret = "bm-nccdemo1"
}

data "google_secret_manager_secret_version" "token2" {
  secret = "bm-nccdemo2"
}

resource "google_network_connectivity_hub" "hub" {
  name          = "bm-nccdemo-hub"
}

module "ncc_spoke1" {
  source = "../../"

  prefix         = "bm-nccdemo1"
  ncc_asn        = 65500
  fgt_asn        = 65501
  ncc_hub_uri    = google_network_connectivity_hub.hub.id
  fgt_api_token  = data.google_secret_manager_secret_version.token.secret_data
  fgt_mgmt_ip    = "34.79.99.75"
  fgt_self_links = [
    "https://www.googleapis.com/compute/v1/projects/forti-emea-se/zones/europe-west1-b/instances/bm-nccdemo-vm1-euwest1-b",
    "https://www.googleapis.com/compute/v1/projects/forti-emea-se/zones/europe-west1-c/instances/bm-nccdemo-vm2-euwest1-c"
  ]
}

module "ncc_spoke2" {
  source = "../../"

  prefix         = "bm-nccdemo2"
  ncc_asn        = 65500
  fgt_asn        = 65502
  ncc_hub_uri    = google_network_connectivity_hub.hub.id
  fgt_api_token  = data.google_secret_manager_secret_version.token2.secret_data
  fgt_mgmt_ip    = "34.30.93.219"
  fgt_self_links = [
    "https://www.googleapis.com/compute/v1/projects/forti-emea-se/zones/us-central1-a/instances/bm-nccdemo-vm1-us-central1-a",
    "https://www.googleapis.com/compute/v1/projects/forti-emea-se/zones/us-central1-b/instances/bm-nccdemo-vm2-us-central1-b"
  ]
}
