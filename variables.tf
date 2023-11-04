# Account info vars
variable "tenancy_ocid" {
  description = "Oracle tenancy ID"
  sensitive   = true
  type        = string
}
variable "user_ocid" {
  description = "Oracle user ID"
  sensitive   = true
  type        = string
}
variable "fingerprint" {
  description = "OCI account fingerprint"
  sensitive   = true
  type        = string
}
variable "private_key_path" {
  description = "/path/to/your-ssh-private-key"
  sensitive   = true
  type        = string
}
variable "public_key_path" {
  description = "/path/to/your-ssh-public-key.pub"
  sensitive   = true
  type        = string
}
variable "compartment_ocid" {
  description = "OCI compartment ID"
  sensitive   = true
  type        = string
}
variable "region" {
  description = "OCI region"
  sensitive   = true
  type        = string
  default     = "uk-london-1"
}
variable "availability_domain" {
  description = "OCI availability domain"
  sensitive   = true
  type        = string
  default     = "IIdQ:UK-LONDON-1-AD-2"
}
variable "availability_domain_number" {
  description = "OCI availability domain number"
  sensitive   = true
  type        = number
  default     = "2"
}
variable "object_storage_url" {
  description = "URL to your Oracle object storage account"
  sensitive   = true
  type        = string
  default     = "https://objectstorage.us-phoenix-1.oraclecloud.com/<my-access-uri>"
}

# Compute vars
variable "vm_name" {
  description = "The name of your VM"
  sensitive   = false
  type        = string
  default     = "minecraft"
}
variable "vm_shape" {
  description = "VM size"
  sensitive   = false
  type        = string
  default     = "VM.Standard.A1.Flex"
}
variable "vm_ocpus" {
  description = "VM CPU count (Oracle CPUs)"
  sensitive   = false
  type        = number
  default     = "4"
}
variable "vm_ram" {
  description = "VM RAM in GB"
  sensitive   = false
  type        = number
  default     = "24"
}
variable "vm_os_image" {
  description = "Image ID for the OS (currently 2023-09) - See the docs https://docs.oracle.com/en-us/iaas/images/image/84a75e6a-f775-4fb8-b934-6104d7c5ea0d/"
  sensitive   = false
  type        = string
  default     = "ocid1.image.oc1.uk-london-1.aaaaaaaadss7wmtwyocobcpmikosddt7bwb6rkvyvua36pvkfig3ezfr2b3a"
}
variable "ssh_key" {
  description = "Your SSH public key to connect to the VM"
  sensitive   = true
  type        = string
}

# Networking vars
variable "net_vcn_name" {
  description = "Virtual network name"
  sensitive   = false
  type        = string
  default     = "vcn"
}
variable "net_subnet_name" {
  description = "Subnet name within the above virtual network"
  sensitive   = false
  type        = string
  default     = "vcn-sub"
}
variable "net_cidr_block" {
  description = "Virtual network size in CIDR notation"
  sensitive   = false
  type        = string
  default     = "10.10.0.0/16"
}
variable "net_subnet" {
  description = "Subnet network size in CIDR notation"
  sensitive   = false
  type        = string
  default     = "10.10.12.0/24"
}

# Cloudflare vars
variable "cf_api_token" {
  description = "Cloudflare API key"
  sensitive   = true
  type        = string
}
variable "cf_zone_id" {
  description = "Cloudflare DNS zone ID"
  sensitive   = true
  type        = string
}
variable "cf_dns_minecraft" {
  description = "Name of your DNS record"
  sensitive   = false
  type        = string
  default     = "minecraft"
}