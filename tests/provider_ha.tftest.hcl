mock_provider "google" {}
mock_provider "time" {}

mock_provider "cato" {
  override_during = plan
}

variables {
  site_name        = "test-site"
  site_description = "Mock HA site"
  region           = "us-east1"
  site_location = {
    city         = "Charleston"
    country_code = "US"
    state_code   = "SC"
    timezone     = "America/New_York"
  }
  subnet_mgmt_cidr          = "10.1.1.0/24"
  subnet_wan_cidr           = "10.1.2.0/24"
  subnet_lan_cidr           = "10.1.3.0/24"
  mgmt_network_ip_primary   = "10.1.1.4"
  wan_network_ip_primary    = "10.1.2.4"
  lan_network_ip_primary    = "10.1.3.4"
  mgmt_network_ip_secondary = "10.1.1.5"
  wan_network_ip_secondary  = "10.1.2.5"
  lan_network_ip_secondary  = "10.1.3.5"
}

run "provider_managed_ha" {
  command   = plan
  state_key = "provider-managed"

  assert {
    condition = (
      cato_socket_site.gcp-site.secondary_vsocket.interface_ip == "10.1.3.5" &&
      cato_socket_site.gcp-site.secondary_vsocket.load_balancer_ip == "10.1.3.6" &&
      google_compute_forwarding_rule.google_compute_forwarding_rule.ip_address == "10.1.3.6" &&
      cato_socket_site.gcp-site.is_cloud_router == null
    )
    error_message = "Default HA must use the provider and the same LAN load balancer IP on both sides."
  }

  assert {
    condition = (
      length(google_compute_instance.secondary_vsocket) == 1 &&
      length(time_sleep.primary_vsocket_upgrade_delay) == 1 &&
      length(cato_wan_interface.wan) == 0
    )
    error_message = "HA must create a secondary VM and keep the primary boot delay, with the default WAN bandwidth."
  }
}

run "cloud_router" {
  command   = plan
  state_key = "cloud-router"

  variables {
    configure_cloud_router_bgp = true
    load_balancer_ip           = "10.1.3.7"
    lan_firewall_rule_name     = null
  }

  assert {
    condition = (
      cato_socket_site.gcp-site.is_cloud_router &&
      cato_socket_site.gcp-site.secondary_vsocket.load_balancer_ip == "10.1.3.7"
    )
    error_message = "Cloud Router mode and the explicit load balancer address must reach the provider."
  }
}

run "assignment_opt_out_requires_existing_ha" {
  command   = plan
  state_key = "existing-assignment"

  variables {
    assign_secondary_on_create = false
  }

  expect_failures = [terraform_data.validate_existing_site]
}

run "single_socket" {
  command   = plan
  state_key = "single-socket"

  variables {
    ha                        = false
    mgmt_network_ip_secondary = null
    wan_network_ip_secondary  = null
    lan_network_ip_secondary  = null
  }

  assert {
    condition = (
      cato_socket_site.gcp-site.secondary_vsocket == null &&
      length(google_compute_instance.secondary_vsocket) == 0 &&
      length(time_sleep.primary_vsocket_upgrade_delay) == 0
    )
    error_message = "Single-socket mode must omit the HA settings, VM, and registration delay."
  }
}

run "cloud_router_without_ha" {
  command   = plan
  state_key = "invalid-cloud-router"

  variables {
    ha                         = false
    configure_cloud_router_bgp = true
  }

  expect_failures = [cato_socket_site.gcp-site]
}

run "record_single_socket_mode" {
  command   = apply
  state_key = "single-mode-marker"

  plan_options {
    target = [terraform_data.deployment_mode]
  }

  variables {
    ha = false
  }
}

run "reject_single_to_ha" {
  command   = plan
  state_key = "single-mode-marker"

  plan_options {
    target = [terraform_data.deployment_mode]
  }

  expect_failures = [terraform_data.deployment_mode]
}

run "record_ha_mode" {
  command   = apply
  state_key = "ha-mode-marker"

  plan_options {
    target = [terraform_data.deployment_mode]
  }
}

run "reject_ha_to_single" {
  command   = plan
  state_key = "ha-mode-marker"

  plan_options {
    target = [terraform_data.deployment_mode]
  }

  variables {
    ha = false
  }

  expect_failures = [terraform_data.deployment_mode]
}
