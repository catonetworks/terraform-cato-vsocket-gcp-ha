
# For AddSecondary API call
variable "token" {
  description = "API token used to authenticate with the Cato Networks API."
  type        = string

  sensitive = true
  validation {
    condition     = can(regex("^[A-Za-z0-9+/]+=*$", var.token)) && length(var.token) >= 16
    error_message = "API token must be a valid base64-encoded string with minimum length of 16 characters."
  }
}

variable "account_id" {
  description = "Account ID used for the Cato Networks integration."
  type        = number
  default     = null
  validation {
    condition     = var.account_id == null || (var.account_id > 0 && var.account_id < 2147483648)
    error_message = "Account ID must be a positive integer less than 2147483648."
  }
}

variable "baseurl" {
  description = "Base URL for the Cato Networks API."
  type        = string
  default     = "https://api.catonetworks.com/api/v1/graphql2"
  validation {
    condition     = can(regex("^https?://[a-zA-Z0-9.-]+(/.*)?$", var.baseurl))
    error_message = "Base URL must be a valid HTTP/HTTPS URL."
  }
}

# Site values
variable "site_name" {
  description = "Name of the vsocket site"
  type        = string
}

variable "site_description" {
  description = "Description of the vsocket site"
  type        = string
}

variable "site_location" {
  description = "Site location information. If all fields are null, location will be automatically determined from the GCP region."
  type = object({
    city         = optional(string)
    country_code = optional(string)
    state_code   = optional(string)
    timezone     = optional(string)
  })
  default = {
    city         = null
    country_code = null
    state_code   = null
    timezone     = null
  }
  validation {
    condition = (
      # Either all fields are null (automatic lookup) or all required fields are provided
      (var.site_location.city == null && var.site_location.country_code == null &&
      var.site_location.state_code == null && var.site_location.timezone == null) ||
      (var.site_location.city != null && var.site_location.country_code != null &&
      var.site_location.timezone != null)
    )
    error_message = "Site location must either have all fields null (for automatic lookup) or provide at minimum city, country_code, and timezone."
  }
}

variable "site_type" {
  description = "The type of the site"
  type        = string
  default     = "CLOUD_DC"
  validation {
    condition     = contains(["DATACENTER", "BRANCH", "CLOUD_DC", "HEADQUARTERS"], var.site_type)
    error_message = "The site_type variable must be one of 'DATACENTER','BRANCH','CLOUD_DC','HEADQUARTERS'."
  }
}

variable "region" {
  description = "GCP Region"
  type        = string
  validation {
    condition     = can(regex("^[a-z]+-[a-z]+[0-9]$", var.region))
    error_message = "Region must be in the format: region-location (e.g., us-central1)."
  }
}

variable "primary_zone" {
  description = "GCP Zone of Primary vSocket"
  type        = string
  default     = null
}

variable "secondary_zone" {
  description = "GCP Zone of Secondary vSocket"
  type        = string
  default     = null
}

variable "vpc_mgmt_name" {
  description = "Management VPC name"
  type        = string
  default     = null
}

variable "vpc_wan_name" {
  description = "WAN VPC name"
  type        = string
  default     = null
}

variable "vpc_lan_name" {
  description = "LAN VPC name"
  type        = string
  default     = null
}

variable "subnet_mgmt_name" {
  description = "Management Subnet name"
  type        = string
  default     = null
}

variable "subnet_wan_name" {
  description = "WAN Subnet name"
  type        = string
  default     = null
}

variable "subnet_lan_name" {
  description = "LAN Subnet name"
  type        = string
  default     = null
}

variable "subnet_mgmt_cidr" {
  description = "Management Subnet CIDR"
  type        = string
  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", var.subnet_mgmt_cidr))
    error_message = "Management Subnet CIDR must be a valid IPv4 CIDR notation."
  }
}

variable "subnet_wan_cidr" {
  description = "WAN Subnet CIDR"
  type        = string
  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", var.subnet_wan_cidr))
    error_message = "WAN Subnet CIDR must be a valid IPv4 CIDR notation."
  }
}

variable "subnet_lan_cidr" {
  description = "LAN Subnet CIDR"
  type        = string
  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", var.subnet_lan_cidr))
    error_message = "LAN Subnet CIDR must be a valid IPv4 CIDR notation."
  }
}

variable "ip_mgmt_name" {
  description = "Management Static IP name"
  type        = string
  default     = null
}

variable "ip_wan_name" {
  description = "WAN Static IP name"
  type        = string
  default     = null
}

variable "boot_disk_size" {
  description = "Boot disk size in GB (minimum 10 GB)"
  type        = number
  default     = 20
  validation {
    condition     = var.boot_disk_size >= 10 && var.boot_disk_size <= 65536
    error_message = "Boot disk size must be between 10 GB and 65536 GB."
  }
}

variable "boot_disk_image" {
  description = "Boot disk image for vSocket instances"
  type        = string
  default     = "projects/cato-vsocket-production/global/images/gcp-socket-image-v22-0-19207"
  validation {
    condition     = can(regex("^projects/[a-z][a-z0-9-]{4,28}[a-z0-9]/global/images/[a-z0-9-]+$", var.boot_disk_image))
    error_message = "Boot disk image must be a valid GCP image path in format: projects/PROJECT/global/images/IMAGE_NAME."
  }
}

variable "machine_type" {
  description = "Machine type for vSocket instances"
  type        = string
  default     = "n2-standard-4"
  validation {
    condition     = can(regex("^[a-z][0-9]-[a-z]+-[0-9]+$", var.machine_type))
    error_message = "Machine type must be in the format: family-series-size (e.g., n2-standard-4)."
  }
}

variable "vm_name" {
  description = "VM Instance name (must be 1-63 characters, lowercase letters, numbers, or hyphens)"
  type        = string
  default     = null
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,61}[a-z0-9]$", var.vm_name)) || var.vm_name == null
    error_message = "VM name must be 1-63 characters long, start with a letter, and contain only lowercase letters, numbers, or hyphens."
  }
}

variable "network_tier" {
  description = "Network tier for the public IP"
  type        = string
  default     = "STANDARD"
  validation {
    condition     = contains(["STANDARD", "PREMIUM"], var.network_tier)
    error_message = "Network tier must be either 'STANDARD' or 'PREMIUM'."
  }
}

variable "mgmt_network_ip_primary" {
  description = "Management network IP  for Primary socket"
  type        = string
  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}$", var.mgmt_network_ip_primary))
    error_message = "Management network IP must be a valid IPv4 address."
  }
}

variable "wan_network_ip_primary" {
  description = "WAN network IP for Primary socket"
  type        = string
  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}$", var.wan_network_ip_primary))
    error_message = "WAN network IP must be a valid IPv4 address."
  }
}

variable "lan_network_ip_primary" {
  description = "LAN network IP for Primary socket"
  type        = string
  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}$", var.lan_network_ip_primary))
    error_message = "LAN network IP must be a valid IPv4 address."
  }
}

variable "mgmt_network_ip_secondary" {
  description = "Management network IP for Secondary socket"
  type        = string
  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}$", var.mgmt_network_ip_secondary))
    error_message = "Management network IP must be a valid IPv4 address."
  }
}

variable "wan_network_ip_secondary" {
  description = "WAN network IP for Secondary socket"
  type        = string
  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}$", var.wan_network_ip_secondary))
    error_message = "WAN network IP must be a valid IPv4 address."
  }
}

variable "lan_network_ip_secondary" {
  description = "LAN network IP for Secondary socket"
  type        = string
  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}$", var.lan_network_ip_secondary))
    error_message = "LAN Network IP must be a valid address"
  }
}

variable "load_balancer_ip" {
  description = "LAN load balancer IP for the site"
  type        = string
  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}$", var.load_balancer_ip))
    error_message = "LAN load balancer IP must be a valid IPv4 address."
  }
}

variable "public_ip_mgmt" {
  description = "Whether to assign the existing static IP to management interface. If false, no public IP will be assigned."
  type        = bool
  default     = true
}

variable "public_ip_wan" {
  description = "Whether to assign the existing static IP to WAN interface. If false, no public IP will be assigned."
  type        = bool
  default     = true
}

# Firewall Configuration
variable "lan_firewall_rule_name" {
  description = "Name of the firewall rule (1-63 chars, lowercase letters, numbers, or hyphens)"
  type        = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,61}[a-z0-9]$", var.lan_firewall_rule_name))
    error_message = "Firewall rule name must be 1-63 characters, start with a letter, and contain only lowercase letters, numbers, or hyphens."
  }
  default = "allow-private-ranges-traffic-in-lan-subnet-fw-rule"
}

variable "create_firewall_rule" {
  description = "Whether to create the firewall rule for lan traffic"
  type        = bool
  default     = true
}

variable "labels" {
  description = "Labels to be appended to GCP resources"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags to be appended to GCP resources"
  type        = list(string)
  default     = []
}

variable "license_id" {
  description = "The license ID for the Cato vSocket of license type CATO_SITE, CATO_SSE_SITE, CATO_PB, CATO_PB_SSE.  Example License ID value: 'abcde123-abcd-1234-abcd-abcde1234567'.  Note that licenses are for commercial accounts, and not supported for trial accounts."
  type        = string
  default     = null
}

variable "license_bw" {
  description = "The license bandwidth number for the cato site, specifying bandwidth ONLY applies for pooled licenses.  For a standard site license that is not pooled, leave this value null. Must be a number greater than 0 and an increment of 10."
  type        = string
  default     = null
}

variable "enable_static_range_translation" {
  description = "Enables the ability to use translated ranges"
  type        = string
  default     = false
}

variable "routed_networks" {
  description = <<EOF
  A map of routed networks to be accessed behind the vSocket site.
  - The key is the logical name for the network.
  - The value is an object containing:
    - "subnet" (string, required): The actual CIDR range of the network.
    - "translated_subnet" (string, optional): The NATed CIDR range if translation is used.
  Example: 
  routed_networks = {
    "Peered-VNET-1" = {
      subnet = "10.100.1.0/24"
    }
    "On-Prem-Network-NAT" = {
      subnet            = "192.168.51.0/24"
      translated_subnet = "10.200.1.0/24"
    }
  }
  EOF
  type = map(object({
    subnet            = string
    translated_subnet = optional(string)
    gateway           = optional(string)
    interface_index   = optional(string, "LAN1")
  }))
  default = {}
}

## Socket interface settings
variable "upstream_bandwidth" {
  description = "Sockets upstream interface WAN Bandwidth in Mbps"
  type        = string
  default     = "null"
}

variable "downstream_bandwidth" {
  description = "Sockets downstream interface WAN Bandwidth in Mbps"
  type        = string
  default     = "null"
}