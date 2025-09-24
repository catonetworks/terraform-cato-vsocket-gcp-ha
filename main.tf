# VPC Networks
resource "google_compute_network" "vpc_mgmt" {
  name                    = var.vpc_mgmt_name
  auto_create_subnetworks = false
}

resource "google_compute_network" "vpc_wan" {
  name                    = var.vpc_wan_name
  auto_create_subnetworks = false
}

resource "google_compute_network" "vpc_lan" {
  name                    = var.vpc_lan_name
  auto_create_subnetworks = false
}

# Subnets
resource "google_compute_subnetwork" "subnet_mgmt" {
  name          = var.subnet_mgmt_name
  ip_cidr_range = var.subnet_mgmt_cidr
  network       = google_compute_network.vpc_mgmt.id
  region        = var.region
}

resource "google_compute_subnetwork" "subnet_wan" {
  name          = var.subnet_wan_name
  ip_cidr_range = var.subnet_wan_cidr
  network       = google_compute_network.vpc_wan.id
  region        = var.region
}

resource "google_compute_subnetwork" "subnet_lan" {
  name          = var.subnet_lan_name
  ip_cidr_range = var.subnet_lan_cidr
  network       = google_compute_network.vpc_lan.id
  region        = var.region
}

# Static IPs
resource "google_compute_address" "primary_ip_mgmt" {
  count        = var.public_ip_mgmt ? 1 : 0
  name         = "${var.ip_mgmt_name}-primary"
  region       = var.region
  network_tier = var.network_tier
}

resource "google_compute_address" "primary_ip_wan" {
  count        = var.public_ip_wan ? 1 : 0
  name         = "${var.ip_wan_name}-primary"
  region       = var.region
  network_tier = var.network_tier
}

resource "google_compute_address" "secondary_ip_mgmt" {
  count        = var.public_ip_mgmt ? 1 : 0
  name         = "${var.ip_mgmt_name}-secondary"
  region       = var.region
  network_tier = var.network_tier
}

resource "google_compute_address" "secondary_ip_wan" {
  count        = var.public_ip_wan ? 1 : 0
  name         = "${var.ip_wan_name}-secondary"
  region       = var.region
  network_tier = var.network_tier
}


########## Start of misc. 
locals {
  primary_name = "${var.vm_name}-primary"
  secondary_name = "${var.vm_name}-secondary"
  load_balancer_name = "${var.vm_name}-lb"
  vsocket_tags = concat(var.tags, ["vsocket"]) 
}

# CMA site
resource "cato_socket_site" "gcp-site" {
  connection_type = "SOCKET_GCP1500"
  description     = var.site_description
  name            = var.site_name
  native_range = {
    native_network_range = var.subnet_lan_cidr
    local_ip             = var.lan_network_ip_primary
  }
  site_location = var.site_location
  site_type     = var.site_type
}

data "cato_accountSnapshotSite" "gcp-site" {
  id = cato_socket_site.gcp-site.id
}

# TODO: Why do we need this? (I see socket has dependency on it, but why?)
resource "null_resource" "destroy_delay" {
  depends_on = [cato_socket_site.gcp-site]

  provisioner "local-exec" {
    when    = destroy
    command = "sleep 30"
  }
}

resource "google_compute_firewall" "allow_rfc1918" {
  count   = var.create_firewall_rule ? 1 : 0
  name    = var.lan_firewall_rule_name
  network = google_compute_subnetwork.subnet_lan.id
  allow {
    protocol = "all" # Allows all protocols (TCP, UDP, ICMP, etc.)
  }
  source_ranges = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16"
  ]
  priority    = 1000 # Standard priority (lower number = higher priority)
  direction   = "INGRESS"
  description = "Allow all RFC1918 private IP ranges to access the cato-lan-vpc network"
}

resource "cato_license" "license" {
  depends_on = [cato_socket_site.gcp-site]
  count      = var.license_id == null ? 0 : 1
  site_id    = cato_socket_site.gcp-site.id
  license_id = var.license_id
  bw         = var.license_bw == null ? null : var.license_bw
}
########## End of misc. 

# Primary vsocket
module "primary-vsocket" {
  depends_on   = [cato_socket_site.gcp-site, null_resource.destroy_delay]
  source                   = "./single_vsocket"
  boot_disk_size           = var.boot_disk_size
  lan_compute_network_id   = google_compute_network.vpc_lan.id
  lan_network_ip           = var.lan_network_ip_primary
  lan_subnet_id            = google_compute_subnetwork.subnet_lan.id
  mgmt_compute_network_id  = google_compute_network.vpc_mgmt.id
  mgmt_network_ip          = var.mgmt_network_ip_primary
  mgmt_static_ip_address   = google_compute_address.primary_ip_mgmt[0].address
  mgmt_subnet_id           = google_compute_subnetwork.subnet_mgmt.id
  vm_name                  = local.primary_name
  wan_compute_network_id   = google_compute_network.vpc_wan.id
  wan_network_ip           = var.wan_network_ip_primary
  wan_static_ip_address    = google_compute_address.primary_ip_wan[0].address
  wan_subnet_id            = google_compute_subnetwork.subnet_wan.id
  zone                     = var.primary_zone
  site_name                = var.site_name
  serial						= data.cato_accountSnapshotSite.gcp-site.info.sockets[0].serial
  tags                     = local.vsocket_tags
  labels                   = var.labels
}

# Time delay to allow for Primary vsocket to upgrade
resource "null_resource" "delay-300" {
  depends_on = [module.primary-vsocket]
  provisioner "local-exec" {
    command = "sleep 300"
  }
}

## Adding secondary and getting its serial
resource "null_resource" "configure_secondary_gcp_vsocket" {
  depends_on = [null_resource.delay-300]

  provisioner "local-exec" {
    command = <<EOF
      # Execute the GraphQL mutation to get the site id
      response=$(curl -k -X POST \
        -H "Accept: application/json" \
        -H "Content-Type: application/json" \
        -H "x-API-Key: ${var.token}" \
        "${var.baseurl}" \
        --data '{
          "query": "mutation siteAddSecondaryGcpVSocket($accountId: ID!, $addSecondaryGcpVSocketInput: AddSecondaryGcpVSocketInput!) {
           	site(accountId: $accountId) { 
           		addSecondaryAzureVSocket(input: $addSecondaryGcpVSocketInput) { id } 
           		} 
           	}",
          "variables": {
            "accountId": "${var.account_id}",
            "addSecondaryGcpVSocketInput": {
            "gcpConfig": {
              "floatingIp": "${var.floating_ip}",
              "interfaceIp": "${var.lan_network_ip_secondary}"
              }
              "site": {
                "by": "ID",
                "input": "${cato_socket_site.gcp-site.id}"
              }
            }
          },
          "operationName": "siteAddSecondaryGcpVSocket"
        }' )
    EOF
  }

  triggers = {
    account_id = var.account_id
    site_id    = cato_socket_site.gcp-site.id
  }
}

# Sleep to allow Secondary vSocket serial retrieval
resource "null_resource" "sleep_30_seconds" {
  provisioner "local-exec" {
    command = "sleep 30"
  }
  depends_on = [null_resource.configure_secondary_gcp_vsocket]
}

# Create Secondary Vsocket Virtual Machine
data "cato_accountSnapshotSite" "gcp-site-for-secondary" {
  depends_on = [null_resource.sleep_30_seconds]
  id         = cato_socket_site.gcp-site.id
}

locals {
  secondary_serial = [for s in data.cato_accountSnapshotSite.gcp-site-for-secondary.info.sockets : s.serial if s.is_primary == false]
}

# Secondary vsocket
module "secondary-vsocket" {
  source                   = "./single_vsocket"
  boot_disk_size           = var.boot_disk_size
  lan_compute_network_id   = google_compute_network.vpc_lan.id
  lan_network_ip           = var.lan_network_ip_secondary
  lan_subnet_id            = google_compute_subnetwork.subnet_lan.id
  mgmt_compute_network_id  = google_compute_network.vpc_mgmt.id
  mgmt_network_ip          = var.mgmt_network_ip_secondary
  mgmt_static_ip_address   = google_compute_address.secondary_ip_mgmt[0].address
  mgmt_subnet_id           = google_compute_subnetwork.subnet_mgmt.id
  vm_name                  = local.secondary_name
  wan_compute_network_id   = google_compute_network.vpc_wan.id
  wan_network_ip           = var.wan_network_ip_secondary
  wan_static_ip_address    = google_compute_address.secondary_ip_wan[0].address
  wan_subnet_id            = google_compute_subnetwork.subnet_wan.id
  zone                     = var.secondary_zone
  site_name                = var.site_name
  serial						= local.secondary_serial
  tags                     = local.vsocket_tags
  labels                   = var.labels
}

# TODO: Might be nicer to have this as a sub-module, if that's fine with our styling guide lines
## Load-balancer resources
# NEG for Primary
resource "google_compute_network_endpoint_group" "primary_neg" {
  name                  = "${local.primary_name}-neg"
  network               = google_compute_network.vpc_lan.id
  subnetwork = google_compute_subnetwork.subnet_lan.id
  zone                  = var.primary_zone
  network_endpoint_type = "GCE_VM_IP"
}

resource "google_compute_network_endpoint" "primary-neg-endpoint" {
  network_endpoint_group = google_compute_network_endpoint_group.primary_neg.name
  instance   = local.primary_name
  ip_address = var.lan_network_ip_primary
  zone = var.primary_zone
}

# NEG for Secondary
resource "google_compute_network_endpoint_group" "secondary_neg" {
  name                  = "${local.secondary_name}-neg"
  network               = google_compute_network.vpc_lan.id
  subnetwork = google_compute_subnetwork.subnet_lan.id
  zone                  = var.secondary_zone
  network_endpoint_type = "GCE_VM_IP"
}

resource "google_compute_network_endpoint" "secondary-neg-endpoint" {
  network_endpoint_group = google_compute_network_endpoint_group.secondary_neg.name
  instance = local.secondary_name
  ip_address = var.lan_network_ip_secondary
  zone = var.secondary_zone
}

# Health check
resource "google_compute_region_health_check" "load-balancer-https-health-check" {
  name        = "${local.load_balancer_name}-https-health-check"

  timeout_sec         = 1
  check_interval_sec  = 1
  healthy_threshold   = 2
  unhealthy_threshold = 2

  https_health_check {
    request_path       = "/cato_healthcheck"
    proxy_header       = "NONE"
    response           = "GCP_HC_OK"
  }
}

# Load-balancer backend service including NEGs as backends
resource "google_compute_region_backend_service" "load-balancer-backend-service" {
  name          = "${local.load_balancer_name}-backend-service"
  health_checks = [google_compute_region_health_check.load-balancer-https-health-check.id]
  load_balancing_scheme = "INTERNAL"
  protocol = "UNSPECIFIED"
  
  # We intentionally set Primary-NEG as 'fail-over' (so that in split-brain case, traffic goes to Secondary)
  backend {
  	balancing_mode = "CONNECTION"
  	group = google_compute_network_endpoint_group.primary_neg.id
  	failover = true
  }
   backend {
   	balancing_mode = "CONNECTION"
  	group = google_compute_network_endpoint_group.secondary_neg.id
  }
}

# Forwarding Rule
resource "google_compute_forwarding_rule" "google_compute_forwarding_rule" {
  name                  = "${local.load_balancer_name}-forwarding-rule"
  region                = var.region
  ip_protocol           = "L3_DEFAULT"
  load_balancing_scheme = "INTERNAL"
  all_ports = true
  backend_service = google_compute_region_backend_service.load-balancer-backend-service.id
  network               = google_compute_network.vpc_lan.id
  subnetwork = google_compute_subnetwork.subnet_lan.id
  ip_address = var.floating_ip
}

# Ingress allow rule for health-checks probes to sockets LAN interfaces
resource "google_compute_firewall" "allow-health-checks-probes-to-sockets-lan" {
  name    = "${local.load_balancer_name}-allow-hc-probes"
  network = google_compute_network.vpc_lan.id

  allow {
    ports    = ["443"]
    protocol = "tcp"
  }

  # sources for health-check queries, described in https://cloud.google.com/load-balancing/docs/health-check-concepts#ip-ranges
  source_ranges = ["35.191.0.0/16","130.211.0.0/22"]
  target_tags   = ["vsocket"]
}


# A Policy Based Route to direct all traffic form LAN to the Load-balancer 
resource "google_network_connectivity_policy_based_route" "route_lan_to_socket" {
  name = "${local.load_balancer_name}-route-lan-to-socket"
  network = google_compute_network.vpc_lan.id
  priority = 1000

  filter {
    protocol_version = "IPV4"
    src_range = google_compute_subnetwork.subnet_lan.ip_cidr_range # TODO: Consider passing additional ranges here ?
    dest_range = "0.0.0.0/0"
  }
  
  next_hop_ilb_ip = google_compute_forwarding_rule.google_compute_forwarding_rule.ip_address
}

# A Policy Based Route to avoid routing socket outgoing traffic back to the load-balancer
resource "google_network_connectivity_policy_based_route" "route_skip_socket" {
  name = "${local.load_balancer_name}-route-skip-socket"
  network = google_compute_network.vpc_lan.id 
  priority = 900

  filter {
    protocol_version = "IPV4"
    src_range = google_compute_subnetwork.subnet_lan.ip_cidr_range # Should be same as used for "route_lan_to_socket"
    dest_range = "0.0.0.0/0"
  }
  
  # This seems to be the way to define "skip other policy-based routes"
  next_hop_other_routes  = "DEFAULT_ROUTING"

  virtual_machine {
    tags = ["vsocket"]
  }
}


