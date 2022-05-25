packer {
  required_plugins {
    outscale = {
      version = ">= 1.0.0"
      source = "github.com/hashicorp/outscale"
    }
  }
}

variable "access_key" {
  type =  string
  default = "$YOUR_ACCESS_KEY"
  // Sensitive vars are hidden from output as of Packer v1.6.5
  sensitive = true
}

variable "secret_key" {
  type =  string
  default = "$YOUR_SECRET_KEY"
  // Sensitive vars are hidden from output as of Packer v1.6.5
  sensitive = true
}

variable "region" {
  type =  string
  default = "$YOUR_REGION"
}

variable "keypair_name" {
  type =  string
  default = "$YOUR_SSH_KEY"
}

variable "the_sg" {
  type =  string
  default = "$YOUR_SG"
}

variable "omi_source" {
  type =  string
  default = "$YOUR_SOURCE_OMI"
}

variable "ssh_path" {
  type =  string
  default = "$PRIVATE_KEY_PATH"
}


source "osc-bsusurrogate" "coreos" {
  region = var.region
  access_key = var.access_key
  secret_key = var.secret_key
  vm_type = "t2.medium"
  ssh_username = "outscale"
  communicator = "ssh"
  ssh_keypair_name = var.keypair_name
  ssh_private_key_file = var.ssh_path
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
  sources = ["source.osc-bsusurrogate.coreos"]
  provisioner "file" {
    source = "remote.ign"
    destination = "/tmp/remote.ign"
  }
  provisioner "shell" {
    inline = [
      "lsblk",
      "sudo yum install epel-release -y",
      "sudo yum install coreos-installer jq screen wget -y",
      "wget -c https://mirror.openshift.com/pub/openshift-v4/x86_64/dependencies/rhcos/latest/rhcos-metal.x86_64.raw.gz",
      "sudo coreos-installer install --insecure -f rhcos-metal.x86_64.raw.gz -i /tmp/remote.ign /dev/sda",
      "lsblk"
    ]
  }
}
