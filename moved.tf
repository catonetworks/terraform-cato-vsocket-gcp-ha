# Preserve the addresses of existing HA infrastructure when adding non-HA mode.
moved {
  from = time_sleep.primary_vsocket_upgrade_delay
  to   = time_sleep.primary_vsocket_upgrade_delay[0]
}

moved {
  from = google_compute_disk.secondary_boot_disk
  to   = google_compute_disk.secondary_boot_disk[0]
}

moved {
  from = google_compute_instance.secondary_vsocket
  to   = google_compute_instance.secondary_vsocket[0]
}

moved {
  from = google_compute_network_endpoint_group.secondary_neg
  to   = google_compute_network_endpoint_group.secondary_neg[0]
}

moved {
  from = google_compute_network_endpoint.secondary-neg-endpoint
  to   = google_compute_network_endpoint.secondary-neg-endpoint[0]
}

moved {
  from = cato_wan_interface.wan
  to   = cato_wan_interface.wan[0]
}
