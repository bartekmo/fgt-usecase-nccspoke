variable fgt_self_links {
  type = list(string)
  default = []
}

variable fgt_mgmt_ip {
  type = string
}

variable fgt_api_token {
  type = string
  sensitive = true
}

variable ncc_asn {
  type = number
}

variable fgt_asn {
  type = number
}

variable ncc_hub_uri {
  type = string
}

variable prefix {
  type = string
  default = ""
}
