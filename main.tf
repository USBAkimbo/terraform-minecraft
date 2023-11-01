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

# Create VM
resource "oci_core_instance" "vm" {
  availability_domain                 = var.availability_domain
  compartment_id                      = var.compartment_ocid
  display_name                        = var.vm_name
  shape                               = var.vm_shape
  is_pv_encryption_in_transit_enabled = "true"

  shape_config {
    ocpus         = var.vm_ocpus
    memory_in_gbs = var.vm_ram
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.vcn-subnet.id
    display_name     = "primaryvnic"
    assign_public_ip = true
    hostname_label   = var.vm_name
  }

  source_details {
    source_type = "image"
    source_id   = var.vm_os_image
  }

  metadata = {
    "ssh_authorized_keys" = "${var.ssh_key}"
  }
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