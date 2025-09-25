# Site outputs
output "site_id" {
  description = "ID of the created Cato site"
  value       = cato_socket_site.gcp-site.id
}

output "site_name" {
  description = "Name of the created Cato site"
  value       = cato_socket_site.gcp-site.name
}

# Primary vSocket outputs
output "primary_boot_disk_name" {
  description = "Boot disk name for the primary vSocket VM"
  value       = google_compute_disk.primary_boot_disk.name
}

output "primary_boot_disk_self_link" {
  description = "Self-link for the primary vSocket boot disk"
  value       = google_compute_disk.primary_boot_disk.self_link
}

output "primary_vm_instance_name" {
  description = "Name of the primary vSocket VM instance"
  value       = google_compute_instance.primary_vsocket.name
}

output "primary_vm_mgmt_network_ip" {
  description = "Management network private IP of the primary vSocket VM"
  value       = google_compute_instance.primary_vsocket.network_interface[0].network_ip
}

output "primary_vm_wan_network_ip" {
  description = "WAN network private IP of the primary vSocket VM"
  value       = google_compute_instance.primary_vsocket.network_interface[1].network_ip
}

output "primary_vm_lan_network_ip" {
  description = "LAN network private IP of the primary vSocket VM"
  value       = google_compute_instance.primary_vsocket.network_interface[2].network_ip
}

output "primary_vm_mgmt_public_ip" {
  description = "Management public IP of the primary vSocket VM if assigned"
  value       = try(google_compute_instance.primary_vsocket.network_interface[0].access_config[0].nat_ip, "No Public IP")
}

output "primary_vm_wan_public_ip" {
  description = "WAN public IP of the primary vSocket VM if assigned"
  value       = try(google_compute_instance.primary_vsocket.network_interface[1].access_config[0].nat_ip, "No Public IP")
}

# Secondary vSocket outputs
output "secondary_boot_disk_name" {
  description = "Boot disk name for the secondary vSocket VM"
  value       = google_compute_disk.secondary_boot_disk.name
}

output "secondary_boot_disk_self_link" {
  description = "Self-link for the secondary vSocket boot disk"
  value       = google_compute_disk.secondary_boot_disk.self_link
}

output "secondary_vm_instance_name" {
  description = "Name of the secondary vSocket VM instance"
  value       = google_compute_instance.secondary_vsocket.name
}

output "secondary_vm_mgmt_network_ip" {
  description = "Management network private IP of the secondary vSocket VM"
  value       = google_compute_instance.secondary_vsocket.network_interface[0].network_ip
}

output "secondary_vm_wan_network_ip" {
  description = "WAN network private IP of the secondary vSocket VM"
  value       = google_compute_instance.secondary_vsocket.network_interface[1].network_ip
}

output "secondary_vm_lan_network_ip" {
  description = "LAN network private IP of the secondary vSocket VM"
  value       = google_compute_instance.secondary_vsocket.network_interface[2].network_ip
}

output "secondary_vm_mgmt_public_ip" {
  description = "Management public IP of the secondary vSocket VM if assigned"
  value       = try(google_compute_instance.secondary_vsocket.network_interface[0].access_config[0].nat_ip, "No Public IP")
}

output "secondary_vm_wan_public_ip" {
  description = "WAN public IP of the secondary vSocket VM if assigned"
  value       = try(google_compute_instance.secondary_vsocket.network_interface[1].access_config[0].nat_ip, "No Public IP")
}

# Load Balancer outputs
output "load_balancer_ip" {
  description = "IP address of the internal load balancer (floating IP)"
  value       = google_compute_forwarding_rule.google_compute_forwarding_rule.ip_address
}

output "load_balancer_name" {
  description = "Name of the load balancer forwarding rule"
  value       = google_compute_forwarding_rule.google_compute_forwarding_rule.name
}

# Network outputs
output "vpc_mgmt_name" {
  description = "Name of the management VPC"
  value       = google_compute_network.vpc_mgmt.name
}

output "vpc_wan_name" {
  description = "Name of the WAN VPC"
  value       = google_compute_network.vpc_wan.name
}

output "vpc_lan_name" {
  description = "Name of the LAN VPC"
  value       = google_compute_network.vpc_lan.name
}

output "subnet_mgmt_name" {
  description = "Name of the management subnet"
  value       = google_compute_subnetwork.subnet_mgmt.name
}

output "subnet_wan_name" {
  description = "Name of the WAN subnet"
  value       = google_compute_subnetwork.subnet_wan.name
}

output "subnet_lan_name" {
  description = "Name of the LAN subnet"
  value       = google_compute_subnetwork.subnet_lan.name
}

# Static IP outputs
output "primary_mgmt_static_ip" {
  description = "Primary management static IP address"
  value       = var.public_ip_mgmt ? google_compute_address.primary_ip_mgmt[0].address : null
}

output "primary_wan_static_ip" {
  description = "Primary WAN static IP address"
  value       = var.public_ip_wan ? google_compute_address.primary_ip_wan[0].address : null
}

output "secondary_mgmt_static_ip" {
  description = "Secondary management static IP address"
  value       = var.public_ip_mgmt ? google_compute_address.secondary_ip_mgmt[0].address : null
}

output "secondary_wan_static_ip" {
  description = "Secondary WAN static IP address"
  value       = var.public_ip_wan ? google_compute_address.secondary_ip_wan[0].address : null
}