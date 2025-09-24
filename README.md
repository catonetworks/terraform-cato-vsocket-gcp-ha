# Cato Networks GCP vSocket HA Terraform Module

The Cato vSocket modules deploys vSocket HA instances to connect to the Cato Cloud.

# Pre-reqs
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

# GCP/Cato vsocket HA Module
module "vsocket-gcp-ha-vnet" {
  source                  = "catonetworks/vsocket-gcp-ha/cato"
  token                   = var.cato_token
  account_id              = var.account_id
  site_name               = "Your-Cato-site-name-here"
  site_description        = "Your Cato site desc here"
  site_location            = {
		city         = "Los Angeles"
		country_code = "US"
		state_code   = "US-CA" ## Optional - for countries with states
		timezone     = "America/Los_Angeles"
	}
  primary_zone = "me-west1-a"
  secondary_zone = "me-west1-b"

  vpc_mgmt_name = "${var.name_prefix}-mgmt-vpc"
  vpc_wan_name = "${var.name_prefix}-wan-vpc"
  vpc_lan_name = "${var.name_prefix}-lan-vpc"
  
  subnet_mgmt_name = "${var.name_prefix}-mgmt-subnet"
  subnet_wan_name = "${var.name_prefix}-wan-subnet"
  subnet_lan_name = "${var.name_prefix}-lan-subnet"

  subnet_mgmt_cidr = "10.3.1.0/24"
  subnet_wan_cidr = "10.3.2.0/24"
  subnet_lan_cidr  = "10.3.3.0/24"
   
  ip_mgmt_name = "${var.name_prefix}-mgmt-public-ip"
  ip_wan_name =  "${var.name_prefix}-wan-public-ip"

  mgmt_network_ip_primary = "10.3.1.4"
  mgmt_network_ip_secondary = "10.3.1.4"

  wan_network_ip_primary = "10.3.2.4"
  wan_network_ip_secondary = "10.3.2.5"

  lan_network_ip_primary          = "10.3.3.4"
  lan_network_ip_secondary        = "10.3.3.5"
  floating_ip             					= "10.3.3.6"  
   
  vm_name = "${var.name_prefix}-vsocket"   
}

```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_cato"></a> [cato](#provider\_cato) | n/a |
| <a name="provider_google"></a> [google](#provider\_google) | n/a |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_primary-vsocket"></a> [primary-vsocket](#module\_primary-vsocket) | ./single_vsocket | n/a |
| <a name="module_secondary-vsocket"></a> [secondary-vsocket](#module\_secondary-vsocket) | ./single_vsocket | n/a |

## Resources

| Name | Type |
|------|------|
| [cato_license.license](https://registry.terraform.io/providers/catonetworks/cato/latest/docs/resources/license) | resource |
| [cato_socket_site.gcp-site](https://registry.terraform.io/providers/catonetworks/cato/latest/docs/resources/socket_site) | resource |
| [google_compute_address.primary_ip_mgmt](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_address.primary_ip_wan](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_address.secondary_ip_mgmt](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_address.secondary_ip_wan](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_firewall.allow-health-checks-probes-to-sockets-lan](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.allow_rfc1918](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_forwarding_rule.google_compute_forwarding_rule](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_forwarding_rule) | resource |
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
| [null_resource.configure_secondary_gcp_vsocket](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.delay-300](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.destroy_delay](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.sleep_30_seconds](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [cato_accountSnapshotSite.gcp-site](https://registry.terraform.io/providers/catonetworks/cato/latest/docs/data-sources/accountSnapshotSite) | data source |
| [cato_accountSnapshotSite.gcp-site-for-secondary](https://registry.terraform.io/providers/catonetworks/cato/latest/docs/data-sources/accountSnapshotSite) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | Account ID used for the Cato Networks integration. | `number` | `null` | no |
| <a name="input_baseurl"></a> [baseurl](#input\_baseurl) | Base URL for the Cato Networks API. | `string` | `"https://api.catonetworks.com/api/v1/graphql2"` | no |
| <a name="input_boot_disk_size"></a> [boot\_disk\_size](#input\_boot\_disk\_size) | Boot disk size in GB (minimum 10 GB) | `number` | `20` | no |
| <a name="input_create_firewall_rule"></a> [create\_firewall\_rule](#input\_create\_firewall\_rule) | Whether to create the firewall rule for lan traffic | `bool` | `true` | no |
| <a name="input_floating_ip"></a> [floating\_ip](#input\_floating\_ip) | LAN floating IP for the site | `string` | n/a | yes |
| <a name="input_ip_mgmt_name"></a> [ip\_mgmt\_name](#input\_ip\_mgmt\_name) | Management Static IP name | `string` | n/a | yes |
| <a name="input_ip_wan_name"></a> [ip\_wan\_name](#input\_ip\_wan\_name) | WAN Static IP name | `string` | n/a | yes |
| <a name="input_labels"></a> [labels](#input\_labels) | Labels to be appended to GCP resources | `map(string)` | `{}` | no |
| <a name="input_lan_firewall_rule_name"></a> [lan\_firewall\_rule\_name](#input\_lan\_firewall\_rule\_name) | Name of the firewall rule (1-63 chars, lowercase letters, numbers, or hyphens) | `string` | `"allow-private-ranges-traffic-in-lan-subnet-fw-rule"` | no |
| <a name="input_lan_network_ip_primary"></a> [lan\_network\_ip\_primary](#input\_lan\_network\_ip\_primary) | LAN network IP for Primary socket | `string` | n/a | yes |
| <a name="input_lan_network_ip_secondary"></a> [lan\_network\_ip\_secondary](#input\_lan\_network\_ip\_secondary) | LAN network IP for Secondary socket | `string` | n/a | yes |
| <a name="input_license_bw"></a> [license\_bw](#input\_license\_bw) | The license bandwidth number for the cato site, specifying bandwidth ONLY applies for pooled licenses.  For a standard site license that is not pooled, leave this value null. Must be a number greater than 0 and an increment of 10. | `string` | `null` | no |
| <a name="input_license_id"></a> [license\_id](#input\_license\_id) | The license ID for the Cato vSocket of license type CATO\_SITE, CATO\_SSE\_SITE, CATO\_PB, CATO\_PB\_SSE.  Example License ID value: 'abcde123-abcd-1234-abcd-abcde1234567'.  Note that licenses are for commercial accounts, and not supported for trial accounts. | `string` | `null` | no |
| <a name="input_mgmt_network_ip_primary"></a> [mgmt\_network\_ip\_primary](#input\_mgmt\_network\_ip\_primary) | Management network IP  for Primary socket | `string` | n/a | yes |
| <a name="input_mgmt_network_ip_secondary"></a> [mgmt\_network\_ip\_secondary](#input\_mgmt\_network\_ip\_secondary) | Management network IP for Secondary socket | `string` | n/a | yes |
| <a name="input_network_tier"></a> [network\_tier](#input\_network\_tier) | Network tier for the public IP | `string` | `"STANDARD"` | no |
| <a name="input_primary_zone"></a> [primary\_zone](#input\_primary\_zone) | GCP Zone of Primary vSocket | `string` | `"me-west1-a"` | no |
| <a name="input_public_ip_mgmt"></a> [public\_ip\_mgmt](#input\_public\_ip\_mgmt) | Whether to assign the existing static IP to management interface. If false, no public IP will be assigned. | `bool` | `true` | no |
| <a name="input_public_ip_wan"></a> [public\_ip\_wan](#input\_public\_ip\_wan) | Whether to assign the existing static IP to WAN interface. If false, no public IP will be assigned. | `bool` | `true` | no |
| <a name="input_region"></a> [region](#input\_region) | GCP Region | `string` | `"me-west1"` | no |
| <a name="input_secondary_zone"></a> [secondary\_zone](#input\_secondary\_zone) | GCP Zone of Secondary vSocket | `string` | `"me-west1-b"` | no |
| <a name="input_site_description"></a> [site\_description](#input\_site\_description) | Description of the vsocket site | `string` | n/a | yes |
| <a name="input_site_location"></a> [site\_location](#input\_site\_location) | n/a | <pre>object({<br/>    city         = string<br/>    country_code = string<br/>    state_code   = string<br/>    timezone     = string<br/>  })</pre> | n/a | yes |
| <a name="input_site_name"></a> [site\_name](#input\_site\_name) | Name of the vsocket site | `string` | n/a | yes |
| <a name="input_site_type"></a> [site\_type](#input\_site\_type) | The type of the site | `string` | `"CLOUD_DC"` | no |
| <a name="input_subnet_lan_cidr"></a> [subnet\_lan\_cidr](#input\_subnet\_lan\_cidr) | LAN Subnet CIDR | `string` | n/a | yes |
| <a name="input_subnet_lan_name"></a> [subnet\_lan\_name](#input\_subnet\_lan\_name) | LAN Subnet name | `string` | n/a | yes |
| <a name="input_subnet_mgmt_cidr"></a> [subnet\_mgmt\_cidr](#input\_subnet\_mgmt\_cidr) | Management Subnet CIDR | `string` | n/a | yes |
| <a name="input_subnet_mgmt_name"></a> [subnet\_mgmt\_name](#input\_subnet\_mgmt\_name) | Management Subnet name | `string` | n/a | yes |
| <a name="input_subnet_wan_cidr"></a> [subnet\_wan\_cidr](#input\_subnet\_wan\_cidr) | WAN Subnet CIDR | `string` | n/a | yes |
| <a name="input_subnet_wan_name"></a> [subnet\_wan\_name](#input\_subnet\_wan\_name) | WAN Subnet name | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to be appended to GCP resources | `list(string)` | `[]` | no |
| <a name="input_token"></a> [token](#input\_token) | API token used to authenticate with the Cato Networks API. | `any` | n/a | yes |
| <a name="input_vm_name"></a> [vm\_name](#input\_vm\_name) | VM Instance name (must be 1-63 characters, lowercase letters, numbers, or hyphens) | `string` | n/a | yes |
| <a name="input_vpc_lan_name"></a> [vpc\_lan\_name](#input\_vpc\_lan\_name) | LAN VPC name | `string` | n/a | yes |
| <a name="input_vpc_mgmt_name"></a> [vpc\_mgmt\_name](#input\_vpc\_mgmt\_name) | Management VPC name | `string` | n/a | yes |
| <a name="input_vpc_wan_name"></a> [vpc\_wan\_name](#input\_vpc\_wan\_name) | WAN VPC name | `string` | n/a | yes |
| <a name="input_wan_network_ip_primary"></a> [wan\_network\_ip\_primary](#input\_wan\_network\_ip\_primary) | WAN network IP for Primary socket | `string` | n/a | yes |
| <a name="input_wan_network_ip_secondary"></a> [wan\_network\_ip\_secondary](#input\_wan\_network\_ip\_secondary) | WAN network IP for Secondary socket | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->