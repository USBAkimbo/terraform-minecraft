# Configure provider versions
terraform {
  required_version = "~> 1.7.5"
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "5.35.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.27.0"
    }
  }
}

# OCI provider
provider "oci" {
  region           = var.region
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
}

# Cloudflare provider
provider "cloudflare" {
  api_token = var.cf_api_token
}