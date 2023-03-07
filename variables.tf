variable "access_key_id" {
    description = "Your Outscale access key"
}
variable "secret_key_id" {
    description = "Your Outscale secret key"
}
variable "region" {
    description = "Your Outscale region"
    default = "eu-west-2"
}
variable "vm_type" {
    description = "The flavor used to deploy the bastion VM"
    default = "tinav4.c1r2p2"
}
variable "image_id" {
    description = "Image ID used to deploy the bastion VM"
    default= "ami-f929abe8"
}

variable "infra_flavor" {
    description = "Image ID used to deploy the infraVM"
    default= "tinav4.c1r2p2"
}

variable "image_infra_id" {
    description = "Image ID used to deploy the infra"
    default= "ami-f929abe8"
}
variable "keypair_name" {
    description = "keypaire name used for bastion VM"
    default = "openshift"
}
variable "dns1_ip" {
    description = "ha proxy DNS server 1 IP"
    default = "192.168.2.200"
}
variable "dns2_ip" {
    description = "DNS server 2 IP"
    default = "8.8.8.8"
}
variable "dns3_ip" {
    description = "1.1.1.1"
    default = "1.1.1.1"
}

variable "master_count" {
    description = "Number of master (minimal 3 for etcd)"
    default = "3"
}

variable "master_flavor" {
    description = "The flavor used to deploy"
    default = "tinav4.c4r8p2"
}

variable "worker_count" {
    description = "Number of worker (minimal is 3)"
    default = "3"
}

variable "worker_flavor" {
    description = "The flavor used to deploy"
    default = "tinav4.c4r8p2"
}

variable "ocp_cluster_name" {
    description = "OCP Cluster name without special characters (example: production)"
    default = "production"
}                                       
variable "ocp_cluster_cidr" {
    description = "OCP Cluster cidr (default: 10.128.0.0/14)"
    default = "10.128.0.0/14"
} 
variable "ocp_service_cidr" {
    description = "OCP Cluster service cidr (default: 172.30.0.0/16)"
    default = "172.30.0.0/16" 
}
variable "ocp_hostprefix" {
    description = "OCP Cluster host prefix (default: 23)"
    default = "23"
}

variable "ocp_networktype" {
    description = "OCP Cluster SDN Type (default: OpenShiftSDN)"
    default = "OpenShiftSDN"
}                                 
variable "ocp_pull_secret" {
     description = "OCP pull secret (retrieve from your redhat account https://console.redhat.com/openshift/)"
}
variable "domain_name" {
     description = "OCP domain sample : outscale.local. fqdn of cluster cop_cluster_name+domain_name => with default value production.outscale.local"
     default = "outscale.local"
}
variable "gitops" {
    description = "Install GitOps on your cluster : true or false"
    default = false
}
variable "user_infra" {
    description = "User for ansible to connect infravm"
    default = "fedora"
}	
variable "haproxy_pwd" {
    description = "Password for haproxy stats"
    default = ""
}



