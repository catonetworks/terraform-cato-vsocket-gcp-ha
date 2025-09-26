
data "cato_accountSnapshotSite" "gcp-site" {
  id = cato_socket_site.gcp-site.id
}

data "cato_accountSnapshotSite" "gcp-site-for-secondary" {
  depends_on = [time_sleep.secondary_serial_delay]
  id         = cato_socket_site.gcp-site.id
}
