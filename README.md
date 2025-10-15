# Cato Networks GCP vSocket HA Terraform Module

Terraform module which creates the GCP resources, VPC, Subnets, network interfaces, firewall rules, route-tables, load balancers, etc.  Then creates and configures a Cato Socket Site and brings up two vSockets in HA configuration. 

## NOTE
- The current API that the Cato provider is calling requires sequential execution. 
Cato recommends setting the value to 1. Example call: terraform apply -parallelism=1.
- This module will look up the Cato Site Location information based on the Location of GCP specified.  If you would like to override this behavior, please leverage the below for help finding the correct values.
- For help with finding exact sytax to match site location for city, state_name, country_name and timezone, please refer to the [cato_siteLocation data source](https://registry.terraform.io/providers/catonetworks/cato/latest/docs/data-sources/siteLocation).
- For help with finding a license id to assign, please refer to the [cato_licensingInfo data source](https://registry.terraform.io/providers/catonetworks/cato/latest/docs/data-sources/licensingInfo).
- For Translated Ranges, "Enable Static Range Translation" but be enabled for more information please refer to [Configuring System Settings for the Account](https://support.catonetworks.com/hc/en-us/articles/4413280536849-Configuring-System-Settings-for-the-Account)

## Pre-reqs
- Install the [Google Cloud Platform CLI](https://cloud.google.com/sdk/docs/install)
`$ /google-cloud-sdk/install.sh`
- Run the following to configure the GCP CLI
`$ gcloud auth application-default login`

## Usage

```hcl
provider "google" {
  project = var.project
  region  = var.region
}

provider "cato" {
  baseurl    = var.baseurl
  token      = var.token
  account_id = var.account_id
}

variable "project" {
  default = "<GCP_Project_ID>"
}
variable "region" {
  default = "<GCP_Region>"
}
variable "baseurl" {}
variable "token" {}
variable "account_id" {}

# GCP/Cato vsocket HA Module
module "vsocket-gcp-ha-vnet" {
  source           = "catonetworks/vsocket-gcp-ha/cato"
  token            = var.token
  account_id       = var.account_id
  site_name        = "<Cato-Site-Name>"
  site_description = "<Cato-Site-Description>"
  region           = var.region

  subnet_mgmt_cidr = "10.3.1.0/24"
  subnet_wan_cidr  = "10.3.2.0/24"
  subnet_lan_cidr  = "10.3.3.0/24"

  mgmt_network_ip_primary   = "10.3.1.4"
  mgmt_network_ip_secondary = "10.3.1.5"

  wan_network_ip_primary   = "10.3.2.4"
  wan_network_ip_secondary = "10.3.2.5"

  lan_network_ip_primary   = "10.3.3.4"
  lan_network_ip_secondary = "10.3.3.5"
  load_balancer_ip         = "10.3.3.6"

  routed_networks = {
    "Peered-VNET-1" = {
      subnet = "10.100.1.0/24"
      # interface_index is omitted, so it will default to "LAN1".
    }
    # "On-Prem-Network-With-NAT" = {
    #   subnet            = "192.168.51.0/24"
    #   translated_subnet = "10.250.3.0/24" # Example translated range, SRT Required, set 
    #   interface_index = "LAN2" # Overriding the default value.
    #   gateway = "192.168.51.254" # Overriding the default value of LAN1 LocalIP
    # }
  }

  upstream_bandwidth   = 1000
  downstream_bandwidth = 1000

  tags   = []
  labels = {}
}
```
## Site Location Reference

For more information on site_location syntax, use the [Cato CLI](https://github.com/catonetworks/cato-cli) to lookup values.

```bash
$ pip3 install catocli
$ export CATO_TOKEN="your-api-token-here"
$ export CATO_ACCOUNT_ID="your-account-id"
$ catocli query siteLocation -h
$ catocli query siteLocation '{"filters":[{"search": "San Diego","field":"city","operation":"exact"}]}' -p
```

## Authors

Module is maintained by [Cato Networks](https://github.com/catonetworks) with help from [these awesome contributors](https://github.com/catonetworks/terraform-cato-vsocket-gcp-ha/graphs/contributors).

## License

Apache 2 Licensed. See [LICENSE](https://github.com/catonetworks/terraform-cato-vsocket-gcp-ha/tree/master/LICENSE) for full details.




<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.5 |
| <a name="requirement_cato"></a> [cato](#requirement\_cato) | ~> 0.0.46 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 7.4 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.2 |
| <a name="requirement_time"></a> [time](#requirement\_time) | ~> 0.13.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_cato"></a> [cato](#provider\_cato) | ~> 0.0.46 |
| <a name="provider_google"></a> [google](#provider\_google) | ~> 7.4 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |
| <a name="provider_time"></a> [time](#provider\_time) | ~> 0.13.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [cato_license.license](https://registry.terraform.io/providers/catonetworks/cato/latest/docs/resources/license) | resource |
| [cato_network_range.routedgcp](https://registry.terraform.io/providers/catonetworks/cato/latest/docs/resources/network_range) | resource |
| [cato_socket_site.gcp-site](https://registry.terraform.io/providers/catonetworks/cato/latest/docs/resources/socket_site) | resource |
| [cato_wan_interface.wan](https://registry.terraform.io/providers/catonetworks/cato/latest/docs/resources/wan_interface) | resource |
| [google_compute_address.primary_ip_mgmt](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_address.primary_ip_wan](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_address.secondary_ip_mgmt](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_address.secondary_ip_wan](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_disk.primary_boot_disk](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_disk) | resource |
| [google_compute_disk.secondary_boot_disk](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_disk) | resource |
| [google_compute_firewall.allow-health-checks-probes-to-sockets-lan](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.allow_rfc1918](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_forwarding_rule.google_compute_forwarding_rule](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_forwarding_rule) | resource |
| [google_compute_instance.primary_vsocket](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |
| [google_compute_instance.secondary_vsocket](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |
| [google_compute_network.vpc_lan](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network) | resource |
| [google_compute_network.vpc_mgmt](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network) | resource |
| [google_compute_network.vpc_wan](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network) | resource |
| [google_compute_network_endpoint.primary-neg-endpoint](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network_endpoint) | resource |
| [google_compute_network_endpoint.secondary-neg-endpoint](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network_endpoint) | resource |
| [google_compute_network_endpoint_group.primary_neg](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network_endpoint_group) | resource |
| [google_compute_network_endpoint_group.secondary_neg](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network_endpoint_group) | resource |
| [google_compute_region_backend_service.load-balancer-backend-service](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_backend_service) | resource |
| [google_compute_region_health_check.load-balancer-https-health-check](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_health_check) | resource |
| [google_compute_subnetwork.subnet_lan](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) | resource |
| [google_compute_subnetwork.subnet_mgmt](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) | resource |
| [google_compute_subnetwork.subnet_wan](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) | resource |
| [google_network_connectivity_policy_based_route.route_lan_to_socket](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/network_connectivity_policy_based_route) | resource |
| [google_network_connectivity_policy_based_route.route_skip_socket](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/network_connectivity_policy_based_route) | resource |
| [terraform_data.configure_secondary_gcp_vsocket](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [time_sleep.primary_vsocket_upgrade_delay](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [time_sleep.secondary_serial_delay](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [time_sleep.site_destroy_delay](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [cato_accountSnapshotSite.gcp-site](https://registry.terraform.io/providers/catonetworks/cato/latest/docs/data-sources/accountSnapshotSite) | data source |
| [cato_accountSnapshotSite.gcp-site-for-secondary](https://registry.terraform.io/providers/catonetworks/cato/latest/docs/data-sources/accountSnapshotSite) | data source |
| [cato_siteLocation.site_location](https://registry.terraform.io/providers/catonetworks/cato/latest/docs/data-sources/siteLocation) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | Account ID used for the Cato Networks integration. | `number` | `null` | no |
| <a name="input_baseurl"></a> [baseurl](#input\_baseurl) | Base URL for the Cato Networks API. | `string` | `"https://api.catonetworks.com/api/v1/graphql2"` | no |
| <a name="input_boot_disk_image"></a> [boot\_disk\_image](#input\_boot\_disk\_image) | Boot disk image for vSocket instances | `string` | `"projects/cato-vsocket-production/global/images/gcp-socket-image-v22-0-19207"` | no |
| <a name="input_boot_disk_size"></a> [boot\_disk\_size](#input\_boot\_disk\_size) | Boot disk size in GB (minimum 10 GB) | `number` | `20` | no |
| <a name="input_create_firewall_rule"></a> [create\_firewall\_rule](#input\_create\_firewall\_rule) | Whether to create the firewall rule for lan traffic | `bool` | `true` | no |
| <a name="input_downstream_bandwidth"></a> [downstream\_bandwidth](#input\_downstream\_bandwidth) | Sockets downstream interface WAN Bandwidth in Mbps | `string` | `"null"` | no |
| <a name="input_enable_static_range_translation"></a> [enable\_static\_range\_translation](#input\_enable\_static\_range\_translation) | Enables the ability to use translated ranges | `string` | `false` | no |
| <a name="input_ip_mgmt_name"></a> [ip\_mgmt\_name](#input\_ip\_mgmt\_name) | Management Static IP name | `string` | `null` | no |
| <a name="input_ip_wan_name"></a> [ip\_wan\_name](#input\_ip\_wan\_name) | WAN Static IP name | `string` | `null` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Labels to be appended to GCP resources | `map(string)` | `{}` | no |
| <a name="input_lan_firewall_rule_name"></a> [lan\_firewall\_rule\_name](#input\_lan\_firewall\_rule\_name) | Name of the firewall rule (1-63 chars, lowercase letters, numbers, or hyphens) | `string` | `"allow-private-ranges-traffic-in-lan-subnet-fw-rule"` | no |
| <a name="input_lan_network_ip_primary"></a> [lan\_network\_ip\_primary](#input\_lan\_network\_ip\_primary) | LAN network IP for Primary socket | `string` | n/a | yes |
| <a name="input_lan_network_ip_secondary"></a> [lan\_network\_ip\_secondary](#input\_lan\_network\_ip\_secondary) | LAN network IP for Secondary socket | `string` | n/a | yes |
| <a name="input_license_bw"></a> [license\_bw](#input\_license\_bw) | The license bandwidth number for the cato site, specifying bandwidth ONLY applies for pooled licenses.  For a standard site license that is not pooled, leave this value null. Must be a number greater than 0 and an increment of 10. | `string` | `null` | no |
| <a name="input_license_id"></a> [license\_id](#input\_license\_id) | The license ID for the Cato vSocket of license type CATO\_SITE, CATO\_SSE\_SITE, CATO\_PB, CATO\_PB\_SSE.  Example License ID value: 'abcde123-abcd-1234-abcd-abcde1234567'.  Note that licenses are for commercial accounts, and not supported for trial accounts. | `string` | `null` | no |
| <a name="input_load_balancer_ip"></a> [load\_balancer\_ip](#input\_load\_balancer\_ip) | LAN load balancer IP for the site | `string` | n/a | yes |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | Machine type for vSocket instances | `string` | `"n2-standard-4"` | no |
| <a name="input_mgmt_network_ip_primary"></a> [mgmt\_network\_ip\_primary](#input\_mgmt\_network\_ip\_primary) | Management network IP  for Primary socket | `string` | n/a | yes |
| <a name="input_mgmt_network_ip_secondary"></a> [mgmt\_network\_ip\_secondary](#input\_mgmt\_network\_ip\_secondary) | Management network IP for Secondary socket | `string` | n/a | yes |
| <a name="input_network_tier"></a> [network\_tier](#input\_network\_tier) | Network tier for the public IP | `string` | `"STANDARD"` | no |
| <a name="input_primary_zone"></a> [primary\_zone](#input\_primary\_zone) | GCP Zone of Primary vSocket | `string` | `null` | no |
| <a name="input_public_ip_mgmt"></a> [public\_ip\_mgmt](#input\_public\_ip\_mgmt) | Whether to assign the existing static IP to management interface. If false, no public IP will be assigned. | `bool` | `true` | no |
| <a name="input_public_ip_wan"></a> [public\_ip\_wan](#input\_public\_ip\_wan) | Whether to assign the existing static IP to WAN interface. If false, no public IP will be assigned. | `bool` | `true` | no |
| <a name="input_region"></a> [region](#input\_region) | GCP Region | `string` | n/a | yes |
| <a name="input_routed_networks"></a> [routed\_networks](#input\_routed\_networks) | A map of routed networks to be accessed behind the vSocket site.<br/>  - The key is the logical name for the network.<br/>  - The value is an object containing:<br/>    - "subnet" (string, required): The actual CIDR range of the network.<br/>    - "translated\_subnet" (string, optional): The NATed CIDR range if translation is used.<br/>  Example: <br/>  routed\_networks = {<br/>    "Peered-VNET-1" = {<br/>      subnet = "10.100.1.0/24"<br/>    }<br/>    "On-Prem-Network-NAT" = {<br/>      subnet            = "192.168.51.0/24"<br/>      translated\_subnet = "10.200.1.0/24"<br/>    }<br/>  } | <pre>map(object({<br/>    subnet            = string<br/>    translated_subnet = optional(string)<br/>    gateway           = optional(string)<br/>    interface_index   = optional(string, "LAN1")<br/>  }))</pre> | `{}` | no |
| <a name="input_secondary_zone"></a> [secondary\_zone](#input\_secondary\_zone) | GCP Zone of Secondary vSocket | `string` | `null` | no |
| <a name="input_site_description"></a> [site\_description](#input\_site\_description) | Description of the vsocket site | `string` | n/a | yes |
| <a name="input_site_location"></a> [site\_location](#input\_site\_location) | Site location information. If all fields are null, location will be automatically determined from the GCP region. | <pre>object({<br/>    city         = optional(string)<br/>    country_code = optional(string)<br/>    state_code   = optional(string)<br/>    timezone     = optional(string)<br/>  })</pre> | <pre>{<br/>  "city": null,<br/>  "country_code": null,<br/>  "state_code": null,<br/>  "timezone": null<br/>}</pre> | no |
| <a name="input_site_name"></a> [site\_name](#input\_site\_name) | Name of the vsocket site | `string` | n/a | yes |
| <a name="input_site_type"></a> [site\_type](#input\_site\_type) | The type of the site | `string` | `"CLOUD_DC"` | no |
| <a name="input_subnet_lan_cidr"></a> [subnet\_lan\_cidr](#input\_subnet\_lan\_cidr) | LAN Subnet CIDR | `string` | n/a | yes |
| <a name="input_subnet_lan_name"></a> [subnet\_lan\_name](#input\_subnet\_lan\_name) | LAN Subnet name | `string` | `null` | no |
| <a name="input_subnet_mgmt_cidr"></a> [subnet\_mgmt\_cidr](#input\_subnet\_mgmt\_cidr) | Management Subnet CIDR | `string` | n/a | yes |
| <a name="input_subnet_mgmt_name"></a> [subnet\_mgmt\_name](#input\_subnet\_mgmt\_name) | Management Subnet name | `string` | `null` | no |
| <a name="input_subnet_wan_cidr"></a> [subnet\_wan\_cidr](#input\_subnet\_wan\_cidr) | WAN Subnet CIDR | `string` | n/a | yes |
| <a name="input_subnet_wan_name"></a> [subnet\_wan\_name](#input\_subnet\_wan\_name) | WAN Subnet name | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to be appended to GCP resources | `list(string)` | `[]` | no |
| <a name="input_token"></a> [token](#input\_token) | API token used to authenticate with the Cato Networks API. | `string` | n/a | yes |
| <a name="input_upstream_bandwidth"></a> [upstream\_bandwidth](#input\_upstream\_bandwidth) | Sockets upstream interface WAN Bandwidth in Mbps | `string` | `"null"` | no |
| <a name="input_vm_name"></a> [vm\_name](#input\_vm\_name) | VM Instance name (must be 1-63 characters, lowercase letters, numbers, or hyphens) | `string` | `null` | no |
| <a name="input_vpc_lan_name"></a> [vpc\_lan\_name](#input\_vpc\_lan\_name) | LAN VPC name | `string` | `null` | no |
| <a name="input_vpc_mgmt_name"></a> [vpc\_mgmt\_name](#input\_vpc\_mgmt\_name) | Management VPC name | `string` | `null` | no |
| <a name="input_vpc_wan_name"></a> [vpc\_wan\_name](#input\_vpc\_wan\_name) | WAN VPC name | `string` | `null` | no |
| <a name="input_wan_network_ip_primary"></a> [wan\_network\_ip\_primary](#input\_wan\_network\_ip\_primary) | WAN network IP for Primary socket | `string` | n/a | yes |
| <a name="input_wan_network_ip_secondary"></a> [wan\_network\_ip\_secondary](#input\_wan\_network\_ip\_secondary) | WAN network IP for Secondary socket | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_load_balancer_ip"></a> [load\_balancer\_ip](#output\_load\_balancer\_ip) | IP address of the internal load balancer (floating IP) |
| <a name="output_load_balancer_name"></a> [load\_balancer\_name](#output\_load\_balancer\_name) | Name of the load balancer forwarding rule |
| <a name="output_primary_boot_disk_name"></a> [primary\_boot\_disk\_name](#output\_primary\_boot\_disk\_name) | Boot disk name for the primary vSocket VM |
| <a name="output_primary_boot_disk_self_link"></a> [primary\_boot\_disk\_self\_link](#output\_primary\_boot\_disk\_self\_link) | Self-link for the primary vSocket boot disk |
| <a name="output_primary_mgmt_static_ip"></a> [primary\_mgmt\_static\_ip](#output\_primary\_mgmt\_static\_ip) | Primary management static IP address |
| <a name="output_primary_vm_instance_name"></a> [primary\_vm\_instance\_name](#output\_primary\_vm\_instance\_name) | Name of the primary vSocket VM instance |
| <a name="output_primary_vm_lan_network_ip"></a> [primary\_vm\_lan\_network\_ip](#output\_primary\_vm\_lan\_network\_ip) | LAN network private IP of the primary vSocket VM |
| <a name="output_primary_vm_mgmt_network_ip"></a> [primary\_vm\_mgmt\_network\_ip](#output\_primary\_vm\_mgmt\_network\_ip) | Management network private IP of the primary vSocket VM |
| <a name="output_primary_vm_mgmt_public_ip"></a> [primary\_vm\_mgmt\_public\_ip](#output\_primary\_vm\_mgmt\_public\_ip) | Management public IP of the primary vSocket VM if assigned |
| <a name="output_primary_vm_wan_network_ip"></a> [primary\_vm\_wan\_network\_ip](#output\_primary\_vm\_wan\_network\_ip) | WAN network private IP of the primary vSocket VM |
| <a name="output_primary_vm_wan_public_ip"></a> [primary\_vm\_wan\_public\_ip](#output\_primary\_vm\_wan\_public\_ip) | WAN public IP of the primary vSocket VM if assigned |
| <a name="output_primary_wan_static_ip"></a> [primary\_wan\_static\_ip](#output\_primary\_wan\_static\_ip) | Primary WAN static IP address |
| <a name="output_secondary_boot_disk_name"></a> [secondary\_boot\_disk\_name](#output\_secondary\_boot\_disk\_name) | Boot disk name for the secondary vSocket VM |
| <a name="output_secondary_boot_disk_self_link"></a> [secondary\_boot\_disk\_self\_link](#output\_secondary\_boot\_disk\_self\_link) | Self-link for the secondary vSocket boot disk |
| <a name="output_secondary_mgmt_static_ip"></a> [secondary\_mgmt\_static\_ip](#output\_secondary\_mgmt\_static\_ip) | Secondary management static IP address |
| <a name="output_secondary_vm_instance_name"></a> [secondary\_vm\_instance\_name](#output\_secondary\_vm\_instance\_name) | Name of the secondary vSocket VM instance |
| <a name="output_secondary_vm_lan_network_ip"></a> [secondary\_vm\_lan\_network\_ip](#output\_secondary\_vm\_lan\_network\_ip) | LAN network private IP of the secondary vSocket VM |
| <a name="output_secondary_vm_mgmt_network_ip"></a> [secondary\_vm\_mgmt\_network\_ip](#output\_secondary\_vm\_mgmt\_network\_ip) | Management network private IP of the secondary vSocket VM |
| <a name="output_secondary_vm_mgmt_public_ip"></a> [secondary\_vm\_mgmt\_public\_ip](#output\_secondary\_vm\_mgmt\_public\_ip) | Management public IP of the secondary vSocket VM if assigned |
| <a name="output_secondary_vm_wan_network_ip"></a> [secondary\_vm\_wan\_network\_ip](#output\_secondary\_vm\_wan\_network\_ip) | WAN network private IP of the secondary vSocket VM |
| <a name="output_secondary_vm_wan_public_ip"></a> [secondary\_vm\_wan\_public\_ip](#output\_secondary\_vm\_wan\_public\_ip) | WAN public IP of the secondary vSocket VM if assigned |
| <a name="output_secondary_wan_static_ip"></a> [secondary\_wan\_static\_ip](#output\_secondary\_wan\_static\_ip) | Secondary WAN static IP address |
| <a name="output_site_id"></a> [site\_id](#output\_site\_id) | ID of the created Cato site |
| <a name="output_site_location_debug"></a> [site\_location\_debug](#output\_site\_location\_debug) | Debug information for site location lookup |
| <a name="output_site_name"></a> [site\_name](#output\_site\_name) | Name of the created Cato site |
| <a name="output_subnet_lan_name"></a> [subnet\_lan\_name](#output\_subnet\_lan\_name) | Name of the LAN subnet |
| <a name="output_subnet_mgmt_name"></a> [subnet\_mgmt\_name](#output\_subnet\_mgmt\_name) | Name of the management subnet |
| <a name="output_subnet_wan_name"></a> [subnet\_wan\_name](#output\_subnet\_wan\_name) | Name of the WAN subnet |
| <a name="output_vpc_lan_name"></a> [vpc\_lan\_name](#output\_vpc\_lan\_name) | Name of the LAN VPC |
| <a name="output_vpc_mgmt_name"></a> [vpc\_mgmt\_name](#output\_vpc\_mgmt\_name) | Name of the management VPC |
| <a name="output_vpc_wan_name"></a> [vpc\_wan\_name](#output\_vpc\_wan\_name) | Name of the WAN VPC |
<!-- END_TF_DOCS -->