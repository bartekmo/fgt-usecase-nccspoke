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

provider "fortios" {
  hostname = var.fgt_mgmt_ip
  token = var.fgt_api_token
  insecure = "true"
}
