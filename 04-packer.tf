data "packer_files" "file-ocp" {
  file = "outscale.pkr.hcl"
}
data "packer_version" "version" {}

resource "packer_image" "omi-rhcos" {
  file = data.packer_files.file-ocp.file
  force     = true
  variables = {
    access_key = var.access_key_id
    secret_key = var.secret_key_id
    region = var.region
    keypair_name = outscale_keypair.ocp_key.keypair_name
    keypair_rsa_file = local_file.ocp_key.filename
  }
  ignore_environment = false
  name               = "ocp"

  triggers = {
    packer_version = data.packer_version.version.version
    files_hash     = data.packer_files.file-ocp.files_hash
  }
     
}


data "outscale_image" "rhcos" {

  filter {
    name   = "image_names"
    values = ["omi_rhcos_user"]
  }
  

  depends_on = [
    packer_image.omi-rhcos
  ]

}






