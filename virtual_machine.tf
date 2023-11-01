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