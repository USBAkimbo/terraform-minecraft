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
    command = "ANSIBLE_FORCE_COLOR=1 ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ubuntu -i '${oci_core_instance.vm.public_ip},' -b ansible-config.yml --vault-password-file ./ansible-vault-key"
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