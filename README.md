# OpenShift on 3DS Outscale

## 1. Description

All this code permits you to deploy an OCP cluster on 3DS Outscale automatically with Ansible. You have the possibility to set your parameters to adapt your cluster to your needs (number of nodes, cpu, memory, disk, etc...).

To install OCP in general, you have two methods :
* IPI : Installer Provide Infrastructure
* UPI : User Provide Infrastructure

## 2. Architecture
 
 ![Schema](docs/ocp-3ds-outscale.svg)

## 3. What this automation do

* Create and deploy a Red Hat CoreOS image for your 3DS OutScale space.

* Deploy all infrastructure part in your OutScale space (VPC, Internet Gatway, route tables, etc...)

* Deploy a bastion VM in your VPC

* Deploy an infrastructure VM with :
	- A DNS server with all needed records for your OCP cluster (api, api-int, *.apps, etc...)
	- A Load Balancer based on HAProxy as endpoint for the OCP cluster with 4 frontends

* Deploy a temporary OCP bootstrap node to install your cluster. This node will be deleted at the end of this automation.

* Deploy 3 OCP master nodes as requested by the user.

* Deploy x OCP worker nodes as requested by the user.

* Deploy GitOps (ArgoCD) on your OCP cluster if you requested it in vars file

To give you an estimate, a cluster with 6 worker nodes takes around 10 - 30 min to be up and running from scratch with this automation (depending your Internet connection)

**Note :** Today, this automation permit only to have master and worker nodes with dynamic IPs provided by 3DS Outscale (DHCP).

## 4. Files organization description

* **terraform files :** files to create needed VPC and network components in your account automatically with Hashicorp Terraform*
* **outscale.pkr.hcl, remote.ign:** filse to create RHCOS images with Hashicorp Packer .. launch by terraform
* **ansible-ocp :** ansible files to create OpenShift Cluster in your Outscale account with end to end automation based on Ansible and Hashicorp Terraform. 

## 5. Prerequisites

- [ ] Your environment have Internet access
- [ ] A 3DS Outscale space
- [ ] One VM bastion used to deploy automation (deploy by step 02)
- [ ] A defined IP for your ocpinfra01 (ex: 192.168.2.200). This server have a major role during deployment (DNS server & LB) and this IP is very important.

## 6. Ready to start?

- **Step 01** : Clone this repository **->** git clone https://github.com/davmartini/ocp_outscale.git
- **Step 02** : Create all network components in your 3DS OutScale space **->** configure vars (export terraform vars or modify variables.tf) and launch terraform init && terraform apply
- **Step 03** : After 10 minutes **->**  follow the output instruction from terraform, all ansible conf is configure for you. Shh key is created on your local folder.
