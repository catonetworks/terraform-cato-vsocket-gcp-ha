output "boot_disk_name" {
  description = "Boot disk name for the VM"
  value       = google_compute_disk.boot_disk.name
}

output "boot_disk_self_link" {
  description = "Self-link for the boot disk"
  value       = google_compute_disk.boot_disk.self_link
}

output "vm_instance_name" {
  description = "Name of the VM instance"
  value       = google_compute_instance.vsocket.name
}

output "vm_mgmt_network_ip" {
  description = "Management network private IP of the VM"
  value       = google_compute_instance.vsocket.network_interface[0].network_ip
}

output "vm_wan_network_ip" {
  description = "WAN network private IP of the VM"
  value       = google_compute_instance.vsocket.network_interface[1].network_ip
}

output "vm_lan_network_ip" {
  description = "LAN network private IP of the VM"
  value       = google_compute_instance.vsocket.network_interface[2].network_ip
}

output "vm_mgmt_public_ip" {
  description = "Management public IP if assigned"
  value       = try(google_compute_instance.vsocket.network_interface[0].access_config[0].nat_ip, "No Public IP")
}

output "vm_wan_public_ip" {
  description = "WAN public IP if assigned"
  value       = try(google_compute_instance.vsocket.network_interface[1].access_config[0].nat_ip, "No Public IP")
}


