variable "project" {
  default = "cato-gcp-cross-connect"
}
variable "region" {
  default = "us-west1"
}
variable "baseurl" {}
variable "token" {}
variable "account_id" {}
variable "name_prefix" {
  default = "jr-test"
}

provider "google" {
  project = var.project
  region  = var.region
}

provider "cato" {
  baseurl    = var.baseurl
  token      = var.token
  account_id = var.account_id
}

# GCP/Cato vsocket HA Module
module "vsocket-gcp-ha-vnet" {
  #   source                  = "catonetworks/vsocket-gcp-ha/cato"
  source           = "../"
  token            = var.token
  account_id       = var.account_id
  site_name        = "Your-Cato-site-name-here"
  site_description = "Your Cato site desc here"
  primary_zone     = "us-west1-a"
  secondary_zone   = "us-west1-b"
  region           = var.region

  vpc_mgmt_name = "${var.name_prefix}-mgmt-vpc"
  vpc_wan_name  = "${var.name_prefix}-wan-vpc"
  vpc_lan_name  = "${var.name_prefix}-lan-vpc"

  subnet_mgmt_name = "${var.name_prefix}-mgmt-subnet"
  subnet_wan_name  = "${var.name_prefix}-wan-subnet"
  subnet_lan_name  = "${var.name_prefix}-lan-subnet"

  subnet_mgmt_cidr = "10.3.1.0/24"
  subnet_wan_cidr  = "10.3.2.0/24"
  subnet_lan_cidr  = "10.3.3.0/24"

  ip_mgmt_name = "${var.name_prefix}-mgmt-public-ip"
  ip_wan_name  = "${var.name_prefix}-wan-public-ip"

  mgmt_network_ip_primary   = "10.3.1.4"
  mgmt_network_ip_secondary = "10.3.1.5"

  wan_network_ip_primary   = "10.3.2.4"
  wan_network_ip_secondary = "10.3.2.5"

  lan_network_ip_primary   = "10.3.3.4"
  lan_network_ip_secondary = "10.3.3.5"
  floating_ip              = "10.3.3.6"

  vm_name = "${var.name_prefix}-vsocket"

  tags   = []
  labels = {}
}