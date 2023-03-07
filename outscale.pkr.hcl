packer {
  required_plugins {
    outscale = {
      version = ">= 1.0.0"
      source  = "github.com/outscale/outscale"
    }
  }
}


variable "access_key" {
  type = string
}
variable "secret_key" {
  type = string
}
variable "region" {
  type = string
}

variable "keypair_name" {
    type = string
}

variable "keypair_rsa_file" {
    type = string
}



variable "omi_source" {
  type =  string
  //default = "ami-e58ac287" // rocky pas redhat bug !!! redhat 9 -> https://docs.outscale.com/fr/userguide/RHEL-9-2022.12.08-0.html
  default = "ami-e58ac287"
}


variable "os_user" {
  type =  string
  default = "outscale"
}


source "outscale-bsusurrogate" "coreos" {
  region = var.region
  access_key = var.access_key
  secret_key = var.secret_key
  vm_type = "t2.medium"
  ssh_username = var.os_user
  communicator = "ssh"
  ssh_keypair_name = var.keypair_name
  ssh_private_key_file = var.keypair_rsa_file
  source_omi = var.omi_source
  omi_name = "omi_rhcos_user"
  launch_block_device_mappings {
    device_name = "/dev/xvdf"
    volume_size = 100
    volume_type = "io1"
    iops = 3000
    delete_on_vm_deletion = true
  }
  omi_root_device {
    source_device_name = "/dev/xvdf"
    device_name = "/dev/sda1"
    delete_on_vm_deletion = true
    volume_size = 100
    volume_type = "io1"
    iops = 3000
  }
}

build {
  name    = "coreos-outscale"
  sources = ["source.outscale-bsusurrogate.coreos"]
  provisioner "file" {
    source = "remote.ign"
    destination = "/tmp/remote.ign"
  }
  provisioner "shell" {
    inline = [
      "lsblk",
      "sudo yum search coreos",
      "sudo yum install jq wget openssl -y",
      "wget -c https://mirror.openshift.com/pub/openshift-v4/clients/coreos-installer/latest/coreos-installer",
      "sudo chmod +x coreos-installer",
      "wget -c https://mirror.openshift.com/pub/openshift-v4/x86_64/dependencies/rhcos/latest/rhcos-metal.x86_64.raw.gz",
      "sudo ./coreos-installer install --insecure -f rhcos-metal.x86_64.raw.gz -i /tmp/remote.ign /dev/sda",
      "lsblk"
    ]
  }
}
