# Cato site variables:
variable "site_name" {
  description = "Name of the vsocket site (used for labels)"
  type        = string
}

variable "vm_name" {
  description = "Name of the vsocket machine"
  type        = string
}


variable "zone" {
  description = "GCP Zone"
  type        = string
  default     = "me-west1-a"
}

# Existing VPC Names (REQUIRED)
variable "mgmt_compute_network_id" {
  description = "ID of existing Management Compute Network"
  type        = string
}

variable "wan_compute_network_id" {
  description = "ID of existing WAN Compute Network"
  type        = string
}

variable "lan_compute_network_id" {
  description = "ID of existing LAN Compute Network"
  type        = string
}

# Existing Subnet Names (REQUIRED)
variable "mgmt_subnet_id" {
  description = "ID of existing Management Subnet"
  type        = string
}

variable "wan_subnet_id" {
  description = "ID of existing WAN Subnet"
  type        = string
}

variable "lan_subnet_id" {
  description = "ID of existing LAN Subnet"
  type        = string
}

# Existing IP Names (REQUIRED)
variable "mgmt_static_ip_address" {
  description = "Name of existing Management Static IP"
  type        = string
}

variable "wan_static_ip_address" {
  description = "Name of existing WAN Static IP"
  type        = string
}

# Boot Disk Configuration
variable "boot_disk_size" {
  description = "Boot disk size in GB (minimum 10 GB)"
  type        = number
  default     = 10
  validation {
    condition     = var.boot_disk_size >= 10
    error_message = "Boot disk size must be at least 10 GB."
  }
}

variable "boot_disk_image" {
  description = "Boot disk image"
  type        = string
  default     = "projects/cato-vsocket-production/global/images/gcp-socket-image-v22-0-19207"
}

variable "network_tier" {
  description = "Network tier for the public IP"
  type        = string
  default     = "STANDARD"
}

# Network IP Configuration (REQUIRED)
variable "mgmt_network_ip" {
  description = "Management network IP"
  type        = string
  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}$", var.mgmt_network_ip))
    error_message = "Management network IP must be a valid IPv4 address."
  }
}

variable "wan_network_ip" {
  description = "WAN network IP"
  type        = string
}

variable "lan_network_ip" {
  description = "LAN network IP"
  type        = string
}

variable "machine_type" {
  description = "Machine type"
  type        = string
  validation {
    condition     = can(regex("^[a-z][0-9]-[a-z]+-[0-9]+$", var.machine_type))
    error_message = "Machine type must be in the format: family-series-size (e.g., n2-standard-4)."
  }
  default = "n2-standard-4"
}

variable "serial" {
  description = "Serial ID for the metadata (Required)"
  type        = string
  validation {
    condition     = length(var.serial) > 0
    error_message = "The serial value is required and cannot be empty."
  }
}

# Public IP Configuration
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

# Labels and tags
variable "labels" {
  description = "Labels to be appended to GCP resources"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags to be appended to GCP resources"
  type        = list(string)
  default     = ["vsocket"]
}

