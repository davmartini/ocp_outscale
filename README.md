# OpenShift on 3DS Outscale

## 1. Description

All this code permits you to deploy an OCP cluster on 3DS Outscale automatically with Ansible. You have the possibility to set your parameters to adapt your cluster to your needs (number of nodes, cpu, memory, disk, etc...).

To install OCP in general, you have two methods :
* IPI : Installer Provide Infrastructure
* UPI : User Provide Infrastructure

## 2. Architecture
 
 ![Schema](docs/ocp-3ds-outscale.svg)

## 3. Files organization description

* 01_ocp_packer_image : files to create RHCOS images with Hashicorp Packer
* 02_ocp_create_network : files to create needed VPC and network components in your account automatically with Hashicorp Terraform
* 03_ocp_install : files to create OpenShift Cluster in your Outscale account with end to end automation based on Ansible and Hashicorp Terraform

## 4. What this automation do

* Deploy an infrastructure VM with :
	- Web server based on Nginx to provide Ignition files to OCP RHCOS nodes
	- A DNS server with all needed records for your OCP cluster (api, api-int, *.apps, etc...)
	- A Load Balancer based on HAProxy as endpoint for the OCP cluster with 4 frontends

* Deploy a temporary OCP bootstrap node to install your cluster. This node will be deleted at the end of this automation.

* Deploy 3 OCP master nodes as requested by the user.

* Deploy x OCP worker nodes as requested by the user.

* Deploy GitOps (ArgoCD) on your OCP cluster if you requested it in vars file

To give you an estimate, a cluster with 6 worker nodes takes around 10 - 30 min to be up and running from scratch with this automation (depending your Internet connection)

**Note :** Today, this automation permit only to have master and worker nodes with dynamic IPs provided by 3DS Outscale (DHCP).

## 5. Prerequisites

- [ ] Your environment have Internet access
- [ ] A 3DS Outscale space
- [ ] Red Hat account with valid subscription (RHEL, AAP, OCP)
	- RHEL8 BaseOS repo : rhel-8-for-x86_64-baseos-rpms
	- RHEL8 AppStream repo : rhel-8-for-x86_64-appstream-rpms
	- AAP2 repo : ansible-automation-platform-2.1-for-rhel-8-x86_64-rpms
- [ ] Ansible Execution Environment : 
	- quay.io/david_martini/ocp_nuta:4.9 to deploy OCP4.9
	- quay.io/david_martini/ocp_nuta:4.10 to deploy OCP4.10
- [ ] One VM bastion used to deploy automation with :
	- RHEL8
	- podman
	- ansible-navigator
	- Ansible Execution Environment with all tools needed by this automation scripts
- [ ] A defined IP for your infravm (ex: 192.168.40.10). This server have a major role during deployment (DNS server & LB) and this IP is very important. This IP can be outside of the DHCP scope to haven't clash IP.