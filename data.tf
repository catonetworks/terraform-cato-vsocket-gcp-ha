data "cato_accountSnapshotSite" "gcp-site" {
  id = cato_socket_site.gcp-site.id
}

data "cato_accountSnapshotSite" "gcp-site-for-secondary" {
  count      = var.ha ? 1 : 0
  depends_on = [time_sleep.secondary_serial_delay]
  id         = cato_socket_site.gcp-site.id
}
