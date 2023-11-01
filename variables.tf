# Account info vars
variable "tenancy_ocid" {
    description = "Oracle tenancy ID"
    sensitive = true
    type = string
}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "public_key_path" {}
variable "compartment_ocid" {}
variable "region" {}
variable "availability_domain" {}
variable "availability_domain_number" {}

# Compute vars
variable "vm_name" {}
variable "vm_shape" {}
variable "vm_ocpus" {}
variable "vm_ram" {}
variable "vm_os_image" {}
variable "ssh_key" {}

# Networking vars
variable "net_vcn_name" {}
variable "net_subnet_name" {}
variable "net_cidr_block" {}
variable "net_subnet" {}

# Cloudflare vars
variable "cf_api_token" {}
variable "cf_zone_id" {}
variable "cf_dns_minecraft" {}