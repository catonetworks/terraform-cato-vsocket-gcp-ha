# VPC Networks
resource "google_compute_network" "vpc_mgmt" {
  name                    = local.vpc_mgmt_name
  auto_create_subnetworks = false
}

resource "google_compute_network" "vpc_wan" {
  name                    = local.vpc_wan_name
  auto_create_subnetworks = false
}

resource "google_compute_network" "vpc_lan" {
  name                    = local.vpc_lan_name
  auto_create_subnetworks = false
}

# Subnets
resource "google_compute_subnetwork" "subnet_mgmt" {
  name          = local.subnet_mgmt_name
  ip_cidr_range = var.subnet_mgmt_cidr
  network       = google_compute_network.vpc_mgmt.id
  region        = var.region
}

resource "google_compute_subnetwork" "subnet_wan" {
  name          = local.subnet_wan_name
  ip_cidr_range = var.subnet_wan_cidr
  network       = google_compute_network.vpc_wan.id
  region        = var.region
}

resource "google_compute_subnetwork" "subnet_lan" {
  name          = local.subnet_lan_name
  ip_cidr_range = var.subnet_lan_cidr
  network       = google_compute_network.vpc_lan.id
  region        = var.region
}

# Static IPs
resource "google_compute_address" "primary_ip_mgmt" {
  count        = var.public_ip_mgmt ? 1 : 0
  name         = "${local.ip_mgmt_name}-primary"
  region       = var.region
  network_tier = var.network_tier
  labels       = var.labels
}

resource "google_compute_address" "primary_ip_wan" {
  count        = var.public_ip_wan ? 1 : 0
  name         = "${local.ip_wan_name}-primary"
  region       = var.region
  network_tier = var.network_tier
  labels       = var.labels
}

resource "google_compute_address" "secondary_ip_mgmt" {
  count        = var.public_ip_mgmt ? 1 : 0
  name         = "${local.ip_mgmt_name}-secondary"
  region       = var.region
  network_tier = var.network_tier
  labels       = var.labels
}

resource "google_compute_address" "secondary_ip_wan" {
  count        = var.public_ip_wan ? 1 : 0
  name         = "${local.ip_wan_name}-secondary"
  region       = var.region
  network_tier = var.network_tier
  labels       = var.labels
}

# DESTROY-TIME DELAY
# This time_sleep resource provides a necessary 10-second delay during destroy operations.
#
# WHY THIS IS NEEDED:
# - During 'terraform destroy', vSocket VMs are destroyed first.
# - The Cato site cleanup happens immediately after.
# - Without a delay, the Cato API may not have finished processing the vSocket
#   disconnections, causing the site destroy operation to fail.
# - This is a known timing issue with the Cato provider during destroy operations.
#

resource "time_sleep" "site_destroy_delay" {
  # This resource has no dependencies during creation, but during destroy it will
  # be destroyed after all resources that depend on the Cato site.
  destroy_duration = "15s"
}

resource "google_compute_firewall" "allow_rfc1918" {
  count   = var.create_firewall_rule ? 1 : 0
  name    = var.lan_firewall_rule_name == null ? format("%s-lan-subnet-fw-rule", var.site_name) : var.lan_firewall_rule_name
  network = google_compute_network.vpc_lan.name
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

# CMA site
resource "cato_socket_site" "gcp-site" {
  depends_on = [time_sleep.site_destroy_delay]

  connection_type = "SOCKET_GCP1500"
  description     = var.site_description
  name            = var.site_name
  native_range = {
    native_network_range = var.subnet_lan_cidr
    local_ip             = var.lan_network_ip_primary
  }
  site_location = local.cur_site_location
  site_type     = var.site_type
}


# Primary vSocket boot disk
resource "google_compute_disk" "primary_boot_disk" {
  depends_on = [cato_socket_site.gcp-site, time_sleep.site_destroy_delay]
  name       = "${local.primary_name}-boot-disk"
  type       = "pd-balanced"
  zone       = local.primary_zone
  size       = var.boot_disk_size
  image      = var.boot_disk_image
  labels     = var.labels
}

# Primary vSocket VM Instance
resource "google_compute_instance" "primary_vsocket" {
  depends_on   = [google_compute_disk.primary_boot_disk]
  name         = local.primary_name
  machine_type = var.machine_type
  zone         = local.primary_zone

  can_ip_forward = true

  boot_disk {
    auto_delete = true
    source      = google_compute_disk.primary_boot_disk.self_link
  }

  # Management interface
  network_interface {
    network    = google_compute_network.vpc_mgmt.id
    subnetwork = google_compute_subnetwork.subnet_mgmt.id
    network_ip = var.mgmt_network_ip_primary
    nic_type   = "GVNIC"

    dynamic "access_config" {
      for_each = var.public_ip_mgmt ? [1] : []
      content {
        nat_ip       = google_compute_address.primary_ip_mgmt[0].address
        network_tier = var.network_tier
      }
    }
  }

  # WAN interface
  network_interface {
    network    = google_compute_network.vpc_wan.id
    subnetwork = google_compute_subnetwork.subnet_wan.id
    network_ip = var.wan_network_ip_primary
    nic_type   = "GVNIC"

    dynamic "access_config" {
      for_each = var.public_ip_wan ? [1] : []
      content {
        nat_ip       = google_compute_address.primary_ip_wan[0].address
        network_tier = var.network_tier
      }
    }
  }

  # LAN interface
  network_interface {
    network    = google_compute_network.vpc_lan.id
    subnetwork = google_compute_subnetwork.subnet_lan.id
    network_ip = var.lan_network_ip_primary
    nic_type   = "GVNIC"
  }

  # Custom metadata with serial id
  metadata = {
    cato-serial-id = local.primary_serial_safe
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  service_account {
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  tags = local.vsocket_tags
  labels = merge(var.labels, {
    name = lower("${var.site_name}-vsocket")
  })
}

# Time delay to allow for Primary vSocket to upgrade
resource "time_sleep" "primary_vsocket_upgrade_delay" {
  depends_on      = [google_compute_instance.primary_vsocket]
  create_duration = "7m"
}

## Adding secondary and getting its serial
# Configure Secondary GCP vSocket via API using terraform_data
resource "terraform_data" "configure_secondary_gcp_vsocket" {
  depends_on = [time_sleep.primary_vsocket_upgrade_delay]

  provisioner "local-exec" {
    # This command is generated from a template to keep the main file clean.
    # It sends a GraphQL mutation to the Cato API endpoint to configure secondary GCP vSocket.
    command = templatefile("${path.module}/templates/configure_secondary_gcp_vsocket.json.tftpl", {
      api_token    = var.token
      base_url     = var.baseurl
      account_id   = var.account_id
      load_balancer_ip  = var.load_balancer_ip
      interface_ip = var.lan_network_ip_secondary
      site_id      = cato_socket_site.gcp-site.id
    })
  }

  triggers_replace = {
    account_id = var.account_id
    site_id    = cato_socket_site.gcp-site.id
  }
}

# Sleep to allow Secondary vSocket serial retrieval
resource "time_sleep" "secondary_serial_delay" {
  depends_on      = [terraform_data.configure_secondary_gcp_vsocket]
  create_duration = "30s"
}


# Secondary vSocket boot disk
resource "google_compute_disk" "secondary_boot_disk" {
  name   = "${local.secondary_name}-boot-disk"
  type   = "pd-balanced"
  zone   = local.secondary_zone
  size   = var.boot_disk_size
  image  = var.boot_disk_image
  labels = var.labels
}

# Secondary vSocket VM Instance
resource "google_compute_instance" "secondary_vsocket" {
  depends_on   = [google_compute_disk.secondary_boot_disk]
  name         = local.secondary_name
  machine_type = var.machine_type
  zone         = local.secondary_zone

  can_ip_forward = true

  boot_disk {
    auto_delete = true
    source      = google_compute_disk.secondary_boot_disk.self_link
  }

  # Management interface
  network_interface {
    network    = google_compute_network.vpc_mgmt.id
    subnetwork = google_compute_subnetwork.subnet_mgmt.id
    network_ip = var.mgmt_network_ip_secondary
    nic_type   = "GVNIC"

    dynamic "access_config" {
      for_each = var.public_ip_mgmt ? [1] : []
      content {
        nat_ip       = google_compute_address.secondary_ip_mgmt[0].address
        network_tier = var.network_tier
      }
    }
  }

  # WAN interface
  network_interface {
    network    = google_compute_network.vpc_wan.id
    subnetwork = google_compute_subnetwork.subnet_wan.id
    network_ip = var.wan_network_ip_secondary
    nic_type   = "GVNIC"

    dynamic "access_config" {
      for_each = var.public_ip_wan ? [1] : []
      content {
        nat_ip       = google_compute_address.secondary_ip_wan[0].address
        network_tier = var.network_tier
      }
    }
  }

  # LAN interface
  network_interface {
    network    = google_compute_network.vpc_lan.id
    subnetwork = google_compute_subnetwork.subnet_lan.id
    network_ip = var.lan_network_ip_secondary
    nic_type   = "GVNIC"
  }

  # Custom metadata with serial id
  metadata = {
    cato-serial-id = local.secondary_serial_safe
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  service_account {
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  tags = local.vsocket_tags
  labels = merge(var.labels, {
    name = lower("${var.site_name}-secondary-vsocket")
  })
}

# TODO: Might be nicer to have this as a sub-module, if that's fine with our styling guide lines
## Load-balancer resources
# NEG for Primary
resource "google_compute_network_endpoint_group" "primary_neg" {
  name                  = "${local.primary_name}-neg"
  network               = google_compute_network.vpc_lan.id
  subnetwork            = google_compute_subnetwork.subnet_lan.id
  zone                  = local.primary_zone
  network_endpoint_type = "GCE_VM_IP"
}

resource "google_compute_network_endpoint" "primary-neg-endpoint" {
  network_endpoint_group = google_compute_network_endpoint_group.primary_neg.name
  instance               = google_compute_instance.primary_vsocket.name
  ip_address             = var.lan_network_ip_primary
  zone                   = local.primary_zone
}

# NEG for Secondary
resource "google_compute_network_endpoint_group" "secondary_neg" {
  name                  = "${local.secondary_name}-neg"
  network               = google_compute_network.vpc_lan.id
  subnetwork            = google_compute_subnetwork.subnet_lan.id
  zone                  = local.secondary_zone
  network_endpoint_type = "GCE_VM_IP"
}

resource "google_compute_network_endpoint" "secondary-neg-endpoint" {
  network_endpoint_group = google_compute_network_endpoint_group.secondary_neg.name
  instance               = google_compute_instance.secondary_vsocket.name
  ip_address             = var.lan_network_ip_secondary
  zone                   = local.secondary_zone
}

# Health check
resource "google_compute_region_health_check" "load-balancer-https-health-check" {
  name = "${local.load_balancer_name}-https-health-check"

  timeout_sec         = 1
  check_interval_sec  = 1
  healthy_threshold   = 2
  unhealthy_threshold = 2

  https_health_check {
    request_path = "/cato_healthcheck"
    proxy_header = "NONE"
    response     = "GCP_HC_OK"
  }
}

# Load-balancer backend service including NEGs as backends
resource "google_compute_region_backend_service" "load-balancer-backend-service" {
  name                  = "${local.load_balancer_name}-backend-service"
  health_checks         = [google_compute_region_health_check.load-balancer-https-health-check.id]
  load_balancing_scheme = "INTERNAL"
  protocol              = "UNSPECIFIED"

  # We intentionally set Primary-NEG as 'fail-over' (so that in split-brain case, traffic goes to Secondary)
  backend {
    balancing_mode = "CONNECTION"
    group          = google_compute_network_endpoint_group.primary_neg.id
    failover       = true
  }
  backend {
    balancing_mode = "CONNECTION"
    group          = google_compute_network_endpoint_group.secondary_neg.id
  }
}

# Forwarding Rule
resource "google_compute_forwarding_rule" "google_compute_forwarding_rule" {
  name                  = "${local.load_balancer_name}-forwarding-rule"
  region                = var.region
  ip_protocol           = "L3_DEFAULT"
  load_balancing_scheme = "INTERNAL"
  all_ports             = true
  backend_service       = google_compute_region_backend_service.load-balancer-backend-service.id
  network               = google_compute_network.vpc_lan.id
  subnetwork            = google_compute_subnetwork.subnet_lan.id
  ip_address            = var.load_balancer_ip
}

# Ingress allow rule for health-checks probes to sockets LAN interfaces
resource "google_compute_firewall" "allow-health-checks-probes-to-sockets-lan" {
  name    = "${local.load_balancer_name}-allow-hc-probes"
  network = google_compute_network.vpc_lan.name

  allow {
    ports    = ["443"]
    protocol = "tcp"
  }

  # sources for health-check queries, described in https://cloud.google.com/load-balancing/docs/health-check-concepts#ip-ranges
  source_ranges = ["35.191.0.0/16", "130.211.0.0/22"]
  target_tags   = ["vsocket"]
}


# A Policy Based Route to direct all traffic form LAN to the Load-balancer 
resource "google_network_connectivity_policy_based_route" "route_lan_to_socket" {
  name     = "${local.load_balancer_name}-route-lan-to-socket"
  network  = google_compute_network.vpc_lan.id
  priority = 1000

  filter {
    protocol_version = "IPV4"
    src_range        = google_compute_subnetwork.subnet_lan.ip_cidr_range # TODO: Consider passing additional ranges here ?
    dest_range       = "0.0.0.0/0"
  }

  next_hop_ilb_ip = google_compute_forwarding_rule.google_compute_forwarding_rule.ip_address
}

# A Policy Based Route to avoid routing socket outgoing traffic back to the load-balancer
resource "google_network_connectivity_policy_based_route" "route_skip_socket" {
  name     = "${local.load_balancer_name}-route-skip-socket"
  network  = google_compute_network.vpc_lan.id
  priority = 900

  filter {
    protocol_version = "IPV4"
    src_range        = google_compute_subnetwork.subnet_lan.ip_cidr_range # Should be same as used for "route_lan_to_socket"
    dest_range       = "0.0.0.0/0"
  }

  # This seems to be the way to define "skip other policy-based routes"
  next_hop_other_routes = "DEFAULT_ROUTING"

  virtual_machine {
    tags = ["vsocket"]
  }
}

resource "cato_network_range" "routedgcp" {
  for_each        = var.routed_networks
  site_id         = cato_socket_site.gcp-site.id
  name            = each.key
  range_type      = "Routed"
  gateway         = coalesce(each.value.gateway, local.lan_first_ip)
  interface_index = each.value.interface_index
  # Access attributes from the value object
  subnet            = each.value.subnet
  translated_subnet = var.enable_static_range_translation ? coalesce(each.value.translated_subnet, each.value.subnet) : null
  # This will be null if not defined, and the provider will ignore it.
}

resource "cato_wan_interface" "wan" {
  site_id              = cato_socket_site.gcp-site.id
  interface_id         = "WAN1"
  name                 = "WAN 1"
  upstream_bandwidth   = var.upstream_bandwidth
  downstream_bandwidth = var.downstream_bandwidth
  role                 = "wan_1"
  precedence           = "ACTIVE"
}
