# ---------------------------------
#         DHCP OPTION
# ---------------------------------
resource "outscale_dhcp_option" "dhcp_option_01" {
    domain_name         = "ocpoutscale.local"
    domain_name_servers = [var.dns1_ip,var.dns2_ip,var.dns3_ip]
    tags {
        key = "Name"
        value = "ocp_dhcp"
    }
}

# ---------------------------------
# VPC ~ Net 
# ---------------------------------
resource "outscale_net" "net01" {
    ip_range = "192.168.0.0/16"
    tags {
      key = "name"
      value = "ocp-net"
    }
}
resource "outscale_net_attributes" "net01_attributes" {
    net_id              = outscale_net.net01.net_id
    dhcp_options_set_id = outscale_dhcp_option.dhcp_option_01.dhcp_options_set_id
}


data "outscale_subregions" "all-subregions" {
}

# ---------------------------------
#              SG
# ---------------------------------
resource "outscale_security_group" "sg-ssh-all" {
  description         = "Permit SSH from All"
  security_group_name = "seg-ssh-all"
  net_id              = outscale_net.net01.net_id
}
data "outscale_security_group" "sg-data-ssh-all" {
  filter {
    name   = "security_group_ids"
    values = [outscale_security_group.sg-ssh-all.security_group_id]
  }
}

resource "outscale_security_group" "sg-all-all" {
  description         = "Permit All from All"
  security_group_name = "seg-all-all"
  net_id              = outscale_net.net01.net_id
}
data "outscale_security_group" "sg-data-all-all" {
  filter {
    name   = "security_group_ids"
    values = [outscale_security_group.sg-all-all.security_group_id]
  }
}

# ---------------------------------
#              SG RULES
# ---------------------------------

##Create_security_group_rule_to_authorize_ssh_access_from_your_public_ip
resource "outscale_security_group_rule" "security_group_rule01" {
  flow              = "Inbound"
  security_group_id = outscale_security_group.sg-ssh-all.id

  from_port_range = "22"
  to_port_range   = "22"

  ip_protocol       = "tcp"
  ip_range    = "0.0.0.0/0"
}

resource "outscale_security_group_rule" "security_group_rule02" {
  flow              = "Inbound"
  security_group_id = outscale_security_group.sg-all-all.id

  ip_protocol       = "-1"
  ip_range    = "0.0.0.0/0"
}


# ---------------------------------
#              SUBNET
# ---------------------------------

resource "outscale_subnet" "subnet-public-aza" {
 net_id              = outscale_net.net01.net_id
 ip_range            = "192.168.1.0/24"
 subregion_name      = data.outscale_subregions.all-subregions.subregions[0].subregion_name
 tags {
    key = "name"
    value = "subnet-public-aza"
     }
}
resource "outscale_subnet" "subnet-public-azb" {
 net_id              = outscale_net.net01.net_id
 ip_range            = "192.168.2.0/24"
 subregion_name      = data.outscale_subregions.all-subregions.subregions[1].subregion_name
 tags {
    key = "name"
    value = "subnet-public-azb"
    }
}

resource "outscale_subnet" "subnet-private-aza" {
 net_id              = outscale_net.net01.net_id
 ip_range            = "192.168.3.0/24"
 subregion_name      = data.outscale_subregions.all-subregions.subregions[0].subregion_name
 tags {
    key = "name"
    value = "subnet-private-aza"
     }
}
resource "outscale_subnet" "subnet-private-azb" {
 net_id              = outscale_net.net01.net_id
 ip_range            = "192.168.4.0/24"
 subregion_name      = data.outscale_subregions.all-subregions.subregions[1].subregion_name
 tags {
    key = "name"
    value = "subnet-private-azb"
    }
}

# ---------------------------------
#               VM
# ---------------------------------
##Create_VMs
#resource "outscale_vm" "vm-priv-azb" {
#  image_id     = var.image_id
#  vm_type      = var.vm_type
#  keypair_name = var.keypair_name
#  subnet_id = outscale_subnet.subnet-private-azb.subnet_id
#  security_group_ids = [outscale_security_group.sg-all.security_group_id] #sg data
#  tags {
#    key = "name"
#    value = "vm-server-priv-azb"
#    }
#}

#in_public_subnet
resource "outscale_vm" "vm-pub-aza" {
  image_id     = var.image_id
  vm_type      = var.vm_type
  keypair_name = var.keypair_name
  subnet_id = outscale_subnet.subnet-public-aza.subnet_id
  security_group_ids = [outscale_security_group.sg-ssh-all.id] #sg resource
  tags {
    key = "name"
    value = "ocpbastion01"
    }
}

# ---------------------------------
#              IGW
# ---------------------------------
##Create_internet_gateway_IGW
resource "outscale_internet_service" "internet_gateway_vpc" {
}

##Attach_IGW_to_VPC
resource "outscale_internet_service_link" "internet_service_link01" {
  internet_service_id = outscale_internet_service.internet_gateway_vpc.internet_service_id
  net_id              = outscale_net.net01.net_id
}

# ---------------------------------
#            NAT
# ---------------------------------

##Create_NAT
resource "outscale_nat_service" "public-nat-aza" {
  subnet_id = outscale_subnet.subnet-public-aza.subnet_id
  public_ip_id = outscale_public_ip.public_ip-NAT_aza.public_ip_id
  tags {
    key = "name"
    value = "pub-nat-aza"
  }
}

#resource "outscale_nat_service" "public-nat-azb" {
#  depends_on = [outscale_route.route-NAT-azb]
#  subnet_id = outscale_subnet.subnet-public-azb.subnet_id
#  public_ip_id = outscale_public_ip.public_ip-NAT_azb.public_ip_id
#  tags {
#    key = "name"
#    value = "pub-nat-azb"
#  }
#}


# ------------------------------------
#             ROUTES
# ------------------------------------


##Create_route_pub_aza
resource "outscale_route_table" "route_table_public_aza" {
   net_id = outscale_net.net01.net_id
   tags {
     key = "name"
     value = "rtb-subnet-public-aza"
   }
}

##Create_route_pub_azb
resource "outscale_route_table" "route_table_public_azb" {
   net_id = outscale_net.net01.net_id
   tags {
     key = "name"
     value = "rtb-subnet-public-azb"
   }
}

##Create_route_priv_aza
resource "outscale_route_table" "route_table_private_aza" {
  net_id = outscale_net.net01.net_id
  tags {
    key = "name"
    value = "rtb-subnet-private-aza"
    }
}

resource "outscale_route_table" "route_table_private_azb" {
  net_id = outscale_net.net01.net_id
  tags {
    key = "name"
    value = "rtb-subnet-private-azb"
    }
}

##Add_route_to_internet_to_route_table_public_aza_subnet_via_IGW
resource "outscale_route" "route-IGW-aza" {
  destination_ip_range = "0.0.0.0/0"
  gateway_id           = outscale_internet_service.internet_gateway_vpc.internet_service_id
  route_table_id       = outscale_route_table.route_table_public_aza.route_table_id
}

##Add_route_to_internet_to_route_table_public_azb_subnet_via_IGW
resource "outscale_route" "route-IGW-azb" {
  destination_ip_range = "0.0.0.0/0"
  gateway_id           = outscale_internet_service.internet_gateway_vpc.internet_service_id
  route_table_id       = outscale_route_table.route_table_public_azb.route_table_id
}

##Add_route_to_internet_to_route_table_private_subnet_via_NAT
resource "outscale_route" "route-NAT-aza" {
  destination_ip_range = "0.0.0.0/0"
  nat_service_id = outscale_nat_service.public-nat-aza.nat_service_id
  route_table_id = outscale_route_table.route_table_private_aza.route_table_id
}

##Add_route_to_internet_to_route_table_private_subnet_via_NAT
resource "outscale_route" "route-NAT-azb" {
  destination_ip_range = "0.0.0.0/0"
  nat_service_id = outscale_nat_service.public-nat-aza.nat_service_id
  route_table_id = outscale_route_table.route_table_private_azb.route_table_id
}

##Attach_route_table_to_public_subnet_aza_to_become_public
resource "outscale_route_table_link" "route_table_public_aza" {
  subnet_id      = outscale_subnet.subnet-public-aza.subnet_id
  route_table_id = outscale_route_table.route_table_public_aza.id
}

##Attach_route_table_to_public_subnet_azb_to_become_public
resource "outscale_route_table_link" "route_table_public_azb" {
  subnet_id      = outscale_subnet.subnet-public-azb.subnet_id
  route_table_id = outscale_route_table.route_table_public_azb.id
}

##Attach_route_table_to_private_subnet_aza_to_become_public
resource "outscale_route_table_link" "route_table_private_aza" {
  subnet_id      = outscale_subnet.subnet-private-aza.subnet_id
  route_table_id = outscale_route_table.route_table_private_aza.id
}

##Attach_route_table_to_private_subnet_azb_to_become_public
resource "outscale_route_table_link" "route_table_private_azb" {
  subnet_id      = outscale_subnet.subnet-private-azb.subnet_id
  route_table_id = outscale_route_table.route_table_private_azb.id
}

# ---------------------------------
#         EIP
# ---------------------------------
##Create_public_ip_for_NAT_aza
resource "outscale_public_ip" "public_ip-NAT_aza" {
  tags {
    key = "name"
    value = "EIP_NAT_AZA"
    }
}
##Create_public_ip_for_NAT_azb
#resource "outscale_public_ip" "public_ip-NAT_azb" {
#  tags {
#    key = "name"
#    value = "EIP_NAT_AZB"
#    }
#}
##Create_public_ip_for_vm_pub
resource "outscale_public_ip" "public_ip_vm" {
  tags {
    key = "name"
    value = "EIP_VM_pub"
    }
}
##Link_EIP_to_VM
resource "outscale_public_ip_link" "public_ip_vm_link" {
  public_ip = outscale_public_ip.public_ip_vm.public_ip
  vm_id = outscale_vm.vm-pub-aza.vm_id
}
