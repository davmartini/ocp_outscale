variable "access_key_id" {
    description = "Your Outscale access key"
}
variable "secret_key_id" {
    description = "Your Outscale secret key"
}
variable "region" {
    description = "Your Outscale region"
}
variable "vm_type" {
    description = "The flavor used to deploy the bastion VM"
}
variable "image_id" {
    description = "Image ID used to deploy the bastion VM"
}
variable "keypair_name" {
    description = "keypaire name used for bastion VM"
}
variable "dns1_ip" {
    description = "DNS server 1 IP"
}
variable "dns2_ip" {
    description = "DNS server 2 IP"
}
variable "dns3_ip" {
    description = "DNS server 3 IP"
}
