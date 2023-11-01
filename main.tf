# Configure provider versions
terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "5.16.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.16.0"
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

# Availability domain config
data "oci_identity_availability_domain" "ad" {
  compartment_id = var.tenancy_ocid
  ad_number      = var.availability_domain_number
}

# Null resource to always run Ansible
resource "null_resource" "ansible" {

  triggers = {
    always_run = "${timestamp()}"
  }

  # Call Ansible to configure the VM
  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ubuntu -i '${oci_core_instance.vm.public_ip},' -b ansible-config.yml --vault-password-file ./ansible-vault-key"
  }
}

# Create DNS A record in Cloudflare
resource "cloudflare_record" "minecraft" {
  zone_id = var.cf_zone_id
  name    = var.cf_dns_minecraft
  value   = oci_core_instance.vm.public_ip
  type    = "A"
  ttl     = 300
}