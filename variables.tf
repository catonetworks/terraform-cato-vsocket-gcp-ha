
# For AddSecondery API call
variable "token" {
  description = "API token used to authenticate with the Cato Networks API."
}

variable "account_id" {
  description = "Account ID used for the Cato Networks integration."
  type        = number
  default     = null
}

variable "baseurl" {
  description = "Base URL for the Cato Networks API."
  type        = string
  default     = "https://api.catonetworks.com/api/v1/graphql2"
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
  type = object({
    city         = string
    country_code = string
    state_code   = string
    timezone     = string
  })
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
  default     = "me-west1"
  validation {
    condition     = can(regex("^[a-z]+-[a-z]+[0-9]$", var.region))
    error_message = "Region must be in the format: region-location (e.g., us-central1)."
  }
}

variable "primary_zone" {
  description = "GCP Zone of Primary vSocket"
  type        = string
  default     = "me-west1-a"
}

variable "secondary_zone" {
  description = "GCP Zone of Secondary vSocket"
  type        = string
  default     = "me-west1-b"
}

variable "vpc_mgmt_name" {
  description = "Management VPC name"
  type        = string
}

variable "vpc_wan_name" {
  description = "WAN VPC name"
  type        = string
}

variable "vpc_lan_name" {
  description = "LAN VPC name"
  type        = string
}

variable "subnet_mgmt_name" {
  description = "Management Subnet name"
  type        = string
}

variable "subnet_wan_name" {
  description = "WAN Subnet name"
  type        = string
}

variable "subnet_lan_name" {
  description = "LAN Subnet name"
  type        = string
}

variable "subnet_mgmt_cidr" {
  description = "Management Subnet CIDR"
  type        = string
}

variable "subnet_wan_cidr" {
  description = "WAN Subnet CIDR"
  type        = string
}

variable "subnet_lan_cidr" {
  description = "LAN Subnet CIDR"
  type        = string
}

variable "ip_mgmt_name" {
  description = "Management Static IP name"
  type        = string
}

variable "ip_wan_name" {
  description = "WAN Static IP name"
  type        = string
}

variable "boot_disk_size" {
  description = "Boot disk size in GB (minimum 10 GB)"
  type        = number
  default     = 20
  validation {
    condition     = var.boot_disk_size >= 10
    error_message = "Boot disk size must be at least 10 GB."
  }
}

variable "vm_name" {
  description = "VM Instance name (must be 1-63 characters, lowercase letters, numbers, or hyphens)"
  type        = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,61}[a-z0-9]$", var.vm_name))
    error_message = "VM name must be 1-63 characters long, start with a letter, and contain only lowercase letters, numbers, or hyphens."
  }
}

variable "network_tier" {
  description = "Network tier for the public IP"
  type        = string
  default     = "STANDARD"
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
}

variable "lan_network_ip_primary" {
  description = "LAN network IP for Primary socket"
  type        = string
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
}

variable "lan_network_ip_secondary" {
  description = "LAN network IP for Secondary socket"
  type        = string
}

variable "floating_ip" {
  description = "LAN floating IP for the site"
  type        = string
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
