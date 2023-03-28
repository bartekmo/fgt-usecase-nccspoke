variable "frontends" {
  type = list(string)
  default = ["aaa", "34.22.189.216", "35.240.31.42", "1.2.3.4" ]
}

variable "prefix" {
  default = "bm-test3"
}

variable "region" {
  default = "europe-west1"
}

locals {
  # split input frontends list into existing and to-be-created EIPs
  in_eip_new = [ for addr in var.frontends : addr if !can(regex( "^\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}$", addr ))]
  in_eip_existing = [ for addr in var.frontends : addr if can(regex( "^\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}$", addr ))]

  # format existing EIP list into mapping by name, skip non-existing addresses, skip IN_USE addresses
  eip_existing_existing = { for addr,info in data.google_compute_addresses.existing : addr => info if length(info.addresses)>0 }
  eip_existing = { for addr,info in local.eip_existing_existing : trimprefix(info.addresses[0].name, "${var.prefix}-") => addr if info.addresses[0].status!="IN_USE"}

  # format new EIP list into mapping by name
  eip_new = {for name,info in google_compute_address.new_eip : name => info.address }

  eip_all = merge( local.eip_new, local.eip_existing )
}

# pull data about existing EIPs to be assigned to the cluster for:
# - sanity check if EIP is available to use
# - getting EIP name for resource naming
data "google_compute_addresses" "existing" {
  for_each = toset(local.in_eip_existing)

  region = var.region
  filter = "address=\"${each.value}\""

# NOTE: in contrary to documentation lifecycle is not supported for data.
#       unavailable addresses will be silently ignored
#  lifecycle {
#    postcondition {
#      condition = length( self.addresses )>0
#      error_message = "Address ${each.value} was not found in region ${var.region}."
#    }
#  }
}

resource "google_compute_address" "new_eip" {
  for_each = toset(local.in_eip_new)

  name                  = "${var.prefix}-eip-${each.value}"
  region                = var.region
  address_type          = "EXTERNAL"
}

output "test" {
  value = local.eip_all
}
