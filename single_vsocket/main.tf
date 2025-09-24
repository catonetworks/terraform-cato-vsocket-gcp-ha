# Boot disk
resource "google_compute_disk" "boot_disk" {
  name  = "${var.vm_name}-boot-disk"
  type  = "pd-balanced"
  zone  = var.zone
  size  = var.boot_disk_size
  image = var.boot_disk_image
}

# VM Instance
resource "google_compute_instance" "vsocket" {
  name         = var.vm_name
  machine_type = var.machine_type
  zone         = var.zone

  can_ip_forward = true

  boot_disk {
    auto_delete = true
    source      = google_compute_disk.boot_disk.self_link
  }

  # Management interface
  network_interface {
    network    = var.mgmt_compute_network_id
    subnetwork = var.mgmt_subnet_id
    network_ip = var.mgmt_network_ip
    nic_type   = "GVNIC"

    dynamic "access_config" {
      for_each = var.public_ip_mgmt ? [1] : []
      content {
        nat_ip       = var.mgmt_static_ip_address
        network_tier = var.network_tier
      }
    }
  }

  # WAN interface
  network_interface {
    network    = var.wan_compute_network_id
    subnetwork = var.wan_subnet_id
    network_ip = var.wan_network_ip
    nic_type   = "GVNIC"

    dynamic "access_config" {
      for_each = var.public_ip_wan ? [1] : []
      content {
        nat_ip       = var.wan_static_ip_address
        network_tier = var.network_tier
      }
    }
  }

  # LAN interface
  network_interface {
    network    = var.lan_compute_network_id
    subnetwork = var.lan_subnet_id
    network_ip = var.lan_network_ip
    nic_type   = "GVNIC"
  }

  # Custom metadata with serial id
  metadata = {
    cato-serial-id = var.serial
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  service_account {
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  tags = var.tags
  labels = merge(var.labels, {
    name = lower("${var.site_name}-vsocket")
  })
}


