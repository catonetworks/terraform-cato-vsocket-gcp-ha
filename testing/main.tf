provider "google" {
  project = var.project
  region  = var.region
}

provider "cato" {
  baseurl    = var.baseurl
  token      = var.token
  account_id = var.account_id
}

variable "project" {
  default = "cato-gcp-cross-connect"
}
variable "region" {
  default = "us-west1"
}
variable "baseurl" {}
variable "token" {}
variable "account_id" {}

# GCP/Cato vsocket HA Module
module "vsocket-gcp-ha-vnet" {
  #   source                  = "catonetworks/vsocket-gcp-ha/cato"
  source           = "../"
  token            = var.token
  account_id       = var.account_id
  site_name        = "jr-gcp-site"
  site_description = "jr-test-gcp-ha-site"
  region           = var.region

  subnet_mgmt_cidr = "10.3.1.0/24"
  subnet_wan_cidr  = "10.3.2.0/24"
  subnet_lan_cidr  = "10.3.3.0/24"

  mgmt_network_ip_primary   = "10.3.1.4"
  mgmt_network_ip_secondary = "10.3.1.5"

  wan_network_ip_primary   = "10.3.2.4"
  wan_network_ip_secondary = "10.3.2.5"

  lan_network_ip_primary   = "10.3.3.4"
  lan_network_ip_secondary = "10.3.3.5"
  floating_ip              = "10.3.3.6"

  routed_networks = {
    "Peered-VNET-1" = {
      subnet = "10.100.1.0/24"
      # interface_index is omitted, so it will default to "LAN1".
    }
    # "On-Prem-Network-With-NAT" = {
    #   subnet            = "192.168.51.0/24"
    #   translated_subnet = "10.250.3.0/24" # Example translated range, SRT Required, set 
    #   interface_index = "LAN2" # Overriding the default value.
    #   gateway = "192.168.51.254" # Overriding the default value of LAN1 LocalIP
    # }
  }

  upstream_bandwidth   = 1000
  downstream_bandwidth = 1000

  tags   = []
  labels = {}
}