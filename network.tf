# Create VCN
resource "oci_core_vcn" "vcn" {
  cidr_block     = var.net_cidr_block
  compartment_id = var.compartment_ocid
  display_name   = var.net_vcn_name
  dns_label      = var.net_vcn_name
}

# Create subnet in VCN
resource "oci_core_subnet" "vcn-subnet" {
  cidr_block        = var.net_cidr_block
  display_name      = var.net_subnet_name
  dns_label         = var.net_subnet_name
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_vcn.vcn.id
  route_table_id    = oci_core_route_table.routetable.id
  security_list_ids = [oci_core_security_list.firewallrules.id]
}

# Firewall rules
resource "oci_core_security_list" "firewallrules" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "Firewall Rules"

  egress_security_rules {
    description = "Allow out"
    protocol    = "6"
    destination = "0.0.0.0/0"
  }

  ingress_security_rules {
    description = "Allow SSH in"
    protocol    = "6"
    source      = "0.0.0.0/0"

    tcp_options {
      max = "22"
      min = "22"
    }
  }

  ingress_security_rules {
    description = "Allow HTTP in"
    protocol    = "6"
    source      = "0.0.0.0/0"

    tcp_options {
      max = "80"
      min = "80"
    }
  }

  ingress_security_rules {
    description = "Allow HTTPS in"
    protocol    = "6"
    source      = "0.0.0.0/0"

    tcp_options {
      max = "443"
      min = "443"
    }
  }

  ingress_security_rules {
    description = "Allow Zabbix Agent2 in"
    protocol    = "6"
    source      = "0.0.0.0/0"

    tcp_options {
      max = "10050"
      min = "10050"
    }
  }

  ingress_security_rules {
    description = "Allow Minecraft in"
    protocol    = "6"
    source      = "0.0.0.0/0"

    tcp_options {
      max = "25565"
      min = "25565"
    }
  }
}

# Create internet gateway so VM has internet access
resource "oci_core_internet_gateway" "internetgateway" {
  compartment_id = var.compartment_ocid
  display_name   = "VCNInternetGateway"
  vcn_id         = oci_core_vcn.vcn.id
}

resource "oci_core_route_table" "routetable" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "RouteTable"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.internetgateway.id
  }
}