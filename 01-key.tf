# create ssh key for conect on all machines

resource "outscale_keypair" "ocp_key" {
    keypair_name = var.keypair_name
}

# store it in order to connect to bastion
resource "local_file" "ocp_key" {
  content     = outscale_keypair.ocp_key.private_key
  filename = "${var.keypair_name}.rsa"
}