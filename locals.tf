locals {
  socket_name        = var.vm_name == null ? format("%s-vsocket", var.site_name) : var.vm_name
  primary_name       = "${local.socket_name}-primary"
  secondary_name     = "${local.socket_name}-secondary"
  load_balancer_name = "${local.socket_name}-lb"
  vsocket_tags       = concat(var.tags, ["vsocket"])
  load_balancer_ip   = var.load_balancer_ip == null ? cidrhost(var.subnet_lan_cidr, 6) : var.load_balancer_ip
  primary_serial     = one([for socket in coalesce(cato_socket_site.gcp-site.sockets, []) : socket.serial_number if socket.is_primary])
  secondary_serial   = one([for socket in coalesce(cato_socket_site.gcp-site.sockets, []) : socket.serial_number if !socket.is_primary])
  lan_first_ip       = cidrhost(var.subnet_lan_cidr, 1)
  primary_zone       = var.primary_zone == null ? "${var.region}-a" : var.primary_zone
  secondary_zone     = var.secondary_zone == null ? "${var.region}-b" : var.secondary_zone
  vpc_mgmt_name      = var.vpc_mgmt_name == null ? format("%s-mgmt-vpc", var.site_name) : var.vpc_mgmt_name
  vpc_wan_name       = var.vpc_wan_name == null ? format("%s-wan-vpc", var.site_name) : var.vpc_wan_name
  vpc_lan_name       = var.vpc_lan_name == null ? format("%s-lan-vpc", var.site_name) : var.vpc_lan_name
  subnet_mgmt_name   = var.subnet_mgmt_name == null ? format("%s-mgmt-subnet", var.site_name) : var.subnet_mgmt_name
  subnet_wan_name    = var.subnet_wan_name == null ? format("%s-wan-subnet", var.site_name) : var.subnet_wan_name
  subnet_lan_name    = var.subnet_lan_name == null ? format("%s-lan-subnet", var.site_name) : var.subnet_lan_name
  ip_mgmt_name       = var.ip_mgmt_name == null ? format("%s-mgmt-public-ip", var.site_name) : var.ip_mgmt_name
  ip_wan_name        = var.ip_wan_name == null ? format("%s-wan-public-ip", var.site_name) : var.ip_wan_name
}