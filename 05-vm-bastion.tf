

# ---------------------------------
#               VM
# ---------------------------------

##Create_public_ip_for_vm_pub
resource "outscale_public_ip" "public_ip_vm" {
  tags {
    key = "name"
    value = "EIP_VM_pub"
    }
}

#in_public_subnet
resource "outscale_vm" "vm-pub-aza" {
  image_id     = var.image_id
  vm_type      = var.vm_type
  keypair_name = outscale_keypair.ocp_key.keypair_name
  subnet_id = outscale_subnet.subnet-public-aza.subnet_id
  security_group_ids = [outscale_security_group.sg-ssh-all.id] #sg resource
  tags {
    key = "name"
    value = "ocpbastion01"
    }
   
}


# ---------------------------------
#         EIP 
# ---------------------------------
##Create_public_ip_for_NAT_aza
#resource "outscale_public_ip" "public_ip-NAT_aza" {
#  tags {
#    key = "name"
#    value = "EIP_NAT_AZA"
#    }
#}
##Create_public_ip_for_NAT_azb
#resource "outscale_public_ip" "public_ip-NAT_azb" {
#  tags {
#    key = "name"
#    value = "EIP_NAT_AZB"
#    }
#}

##Link_EIP_to_VM
resource "outscale_public_ip_link" "public_ip_vm_link" {
  public_ip = outscale_public_ip.public_ip_vm.public_ip
  vm_id = outscale_vm.vm-pub-aza.vm_id
     connection {
            type     = "ssh"
            user     = "fedora"
            private_key = file(local_file.ocp_key.filename)
            host     = outscale_public_ip.public_ip_vm.public_ip 
        }
  provisioner "remote-exec" {
    inline = [
      "echo 'INSTALL' ",
      "sudo dnf install -y vim bind-utils jq podman python3-pip",
      "echo 'INSTALL ansible-navigator' ",
      "python3 -m pip install ansible-navigator --user ",
      "echo 'INSTALL container ocp_outscale' ",
      "podman pull quay.io/david_martini/ocp_outscale:4.11",
      "mkdir -p  ansible-ocp/ansible/vars",
      "echo 'INSTALL rsa key generate for the project'",
      "echo '${outscale_keypair.ocp_key.private_key}' > ansible-ocp/${local_file.ocp_key.filename}",
      "chmod 600 ansible-ocp/${local_file.ocp_key.filename}"
    ]
  }
  provisioner "file" {
        content     = templatefile("templates/vars.tftpl",{
        domain_name        = var.domain_name,
        worker_count       = var.worker_count,
        worker_flavor      = var.worker_flavor,
        master_count       = var.master_count,
        master_flavor      = var.master_flavor,
        ocp_cluster_name   = var.ocp_cluster_name,
        ocp_cluster_cidr   = var.ocp_cluster_cidr,
        ocp_pull_secret    = var.ocp_pull_secret,
        ocp_networktype    = var.ocp_networktype,
        ocp_hostprefix     = var.ocp_hostprefix,
        ocp_service_cidr   = var.ocp_service_cidr,
        coreos_omi         = "${data.outscale_image.rhcos.image_id}",
        gitops             = var.gitops,
        outscale_sg        = outscale_security_group.sg-all-all.security_group_id,
        ocp-key            = var.keypair_name,
        ocp-key-private    = local_file.ocp_key.filename,
        infravm_ip         = var.dns1_ip,
        infravm_flavor     = var.infra_flavor,
        user_infra         = var.user_infra,
        infra_omi_id       = var.image_infra_id
        haproxy_pwd        = var.haproxy_pwd,
        subnet_id_infravm  = outscale_subnet.subnet-public-azb.subnet_id,
        subnet_id_master   = outscale_subnet.subnet-private-aza.subnet_id,
        subnet_id_worker   = outscale_subnet.subnet-private-azb.subnet_id ,
        outscale_ak        = var.access_key_id,
        outscale_sk        = var.secret_key_id,
        outscale_region    = var.region
      })
     destination = "ansible-ocp/ansible/vars/vars.yaml"
   }
  provisioner "remote-exec" {
    inline = [
      "PUBKEY=$(cat $HOME/.ssh/authorized_keys) && sed -i \"s#XXXX_PUBLIC_KEY_XXXXX#$PUBKEY#g\" ansible-ocp/ansible/vars/vars.yaml"
    ]
  }
  provisioner "file" {
    source      = "ansible-ocp"
    destination = "."
  }
    depends_on = [
      packer_image.omi-rhcos
    ]
}





output "command" {
  value = "Connect to bastion with the following command ssh -i ${local_file.ocp_key.filename} fedora@${outscale_public_ip.public_ip_vm.public_ip} run the followin command cd ansible-ocp && ansible-navigator run ansible/main.yml -i ansible/inventory --eei quay.io/david_martini/ocp_outscale:4.11 -m stdout --pae false --lf /tmp/ansible-navigator.log "
}
