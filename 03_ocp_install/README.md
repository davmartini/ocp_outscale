# OCP Install automation with Ansible

## 1. Description

All this code permits you to deploy an OCP cluster on Nutanix AHV automatically with Ansible. You have the possibility to set your parameters to adapt your cluster to your needs (number of nodes, cpu, memory, disk, etc...).

To install OCP in general, you have two methods :
* IPI : Installer Provide Infrastructure
* UPI : User Provide Infrastructure

Today (December 2021), the IPI option isn't available for Nutanix AHV. It's for that we provide this automation based on Ansible, Terraform and UPI to standarized installation awaiting IPI planned in H2 2021.

## 2. What this automation do

* Deploy an infrastructure VM with :
	- Web server based on Nginx to provide Ignition files to OCP RHOCS nodes
	- A DNS server with all needed records for your OCP cluster (api, api-int, *.apps, etc...)
	- A Load Balancer based on HAProxy as endpoint for the OCP cluster with 4 frontends

* Deploy a temporary OCP bootstrap node to install your cluster. This node will be deleted at the end of this automation.

* Deploy 3 OCP master nodes as requested by the user.

* Deploy x OCP worker nodes as requested by the user.

* Deploy GitOps (ArgoCD) on your OCP cluster if you requested it in vars file

* Deploy Nutanix CSI operator and configuration on your OCP cluster if you requested it in vars file

To give you an estimate, a cluster with 6 worker nodes takes around 10 - 30 min to be up and running from scratch with this automation (depending your Internet connection)

**Note :** Today, this automation permit only to have master and worker nodes with dynamic IPs provided by Nutanix AOS IPAM (DHCP).

## 3. Prerequisites

- [ ] Your environment have Internet access
- [ ] Nutanix AOS cluster with admin access
- [ ] A Nutanix AOS subnet with IPAM enable
- [ ] Red Hat account with valid subscription (RHEL, AAP, OCP)
	- RHEL8 BaseOS repo : rhel-8-for-x86_64-baseos-rpms
	- RHEL8 AppStream repo : rhel-8-for-x86_64-appstream-rpms
	- AAP2 repo : ansible-automation-platform-2.1-for-rhel-8-x86_64-rpms
- [ ] QCOW2 images imported on Nutanix AHV cluster :
	- RHEL8 KVM image (ex: Red Hat Enterprise Linux 8.5 Update KVM Guest Image)
	- RHCOS OpenStack image
		- https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/4.9/latest/rhcos-4.9.0-x86_64-openstack.x86_64.qcow2.gz
		- or 
		- https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/4.10/latest/rhcos-4.10.3-x86_64-nutanix.x86_64.qcow2.gz)
- [ ] Ansible Execution Environment : 
	- quay.io/david_martini/ocp_nuta:4.9 to deploy OCP4.9
	- quay.io/david_martini/ocp_nuta:4.10 to deploy OCP4.10
- [ ] One VM bastion used to deploy automation with :
	- RHEL8
	- podman
	- ansible-navigator
	- Ansible Execution Environment with all tools needed by this automation scripts
- [ ] A defined IP for your infravm (ex: 192.168.40.10). This server have a major role during deployment (DNS server & LB) and this IP is very important. This IP can be outside of the DHCP scope to haven't clash IP.
	

## 4. Deployment

All steps must be done on your RHEL8 VM Bastion or your RHEL8 workstation connected to the Internet (to pull image) with direct access to your Nutanix cluster. 

✅ **Please read the entire documentation step by step to deploy without error**

**1. Register your RHEL8 VM Bastion**
```
subscription-manager register
```

**2. Attach a subsciption to your RHEL8 VM Bastion**
```
subscription-manager attach --pool=<your pool ID>
```

**3. Enable needed repos on RHEL8 VM Bastion**
```
subscription-manager repos --enable=rhel-8-for-x86_64-baseos-rpms \
--enable=rhel-8-for-x86_64-appstream-rpms \
--enable=ansible-automation-platform-2.1-for-rhel-8-x86_64-rpms
```

**4. Install tools and utilities on RHEL8 VM Bastion**
```
dnf install git vim bind-utils jq podman ansible-navigator
```

**5. Pull Ansible EE with all embedded tools on your RHEL8 VM Bastion**
```
podman pull quay.io/david_martini/ocp_nuta:4.x
```

**6. Clone GIT repository on your RHEL8 VM Bastion**
```
git clone https://github.com/davmartini/rh_nutanix_fr.git
```

**7. Go to GIT workspace and edit vars file with your configuration**
```
cd $PATH/rh_nutanix_fr/ocp_install/
vim ansible/vars/vars.yaml
```

**8. Add infravm IP you chosen as DNS server on your Nutanix AHV network where you deploy your OCP cluster throught Prism interface. This IP must be the IP DNS server for the subnet**
```
Prism > Network & Security > Subnets > Select your network > Actions > Update
```

With this configuration, OCP nodes will request to infravm to resolve your cluster DNS records and install properly all needed.

**9. Custom DNS on VM Bastion**

All the automation is embedded in a container and your don't need to install extra tools directly on your bastion. Howerver, this container or Execution Environment need to resolv OCP cluster records to install properly it.

The container or Execution Environment inherite of DNS configuration you have on your Bastion. Before to start the deployment you must so add the infravm IP as **first** DNS server as follow :

```
# Generated by NetworkManager
search nutarh.io
nameserver ${infravmip}
nameserver 10.42.32.10
nameserver 10.42.32.11
```


**10. Deploy your cluster with Ansible**
> :heavy_exclamation_mark: Before to deploy your cluster, be sure your have configured infravm IP as first DNS server in IPAM configuration of your AOS subnet.
```
ansible-navigator run ansible/main.yml -i ansible/inventory --eei quay.io/david_martini/ocp_nuta:4.x -m stdout --pae false --lf /tmp/ansible-navigator.log
```

**11. Cluster information**

A the end of automatic deployment, all needed information to connet to your cluster will be printed (kubeconfig, URL, kubeadmin-passowrd). 
> :heavy_exclamation_mark: Be sure to save these informations. If you lose them, you couldn't connect to your cluster and you will have no possibility to recover them

## 5. Access to your custer
You can access to you fresh installed cluster from your remote computer to define infravm IP as DNS server. You can also follow this steps bellow if you are on mac.

* Create direcotry as root on your mac
```
sudo mkdir /etc/resolver/
```

* Create domain file where ${domain} is the domain you chosen during OCP deployment and ${infravmip} is the infravm IP you chosen.
```
sudo bash -c 'echo "nameserver ${infravmip}" > /etc/resolver/${domain}'
example :
sudo bash -c 'echo "nameserver 192.168.40.10" > /etc/resolver/domain.io'
```

* Verify your new DNS configuration on your computer
```
scutil --dns 
---
resolver #11
  domain   : domain.io
  nameserver[0] : 192.168.40.10
  flags    : Request A records, Request AAAA records
  reach    : 0x00000002 (Reachable)
---
```
All DNS requests concerning the domain **domain.io** will be forwarded to **192.168.40.10** DNS server 

## 6. More information

* You can check needed variables with **vars.yaml.example** example.
* You have access to HAProxy stats for each frontend on the URL : http://${Infra VM IP}:5000/stats. You will need to set a stats password in the vars file.
* To access your cluster from a remote computer, you have to add infravm IP as DNS server in your own network configuration.

## 7. Day 2 operation

* Enable a container registry for your OpenShift Cluster: [Registry configuration](https://docs.openshift.com/container-platform/4.9/installing/installing_platform_agnostic/installing-platform-agnostic.html#installation-registry-storage-config_installing-platform-agnostic)
* Configure persistent storage for Monitoring stack: [Monitoring configuration](https://docs.openshift.com/container-platform/4.9/monitoring/configuring-the-monitoring-stack.html#configuring-persistent-storage)
* Enable authentification provider: [Auth configuration](https://docs.openshift.com/container-platform/4.9/authentication/understanding-authentication.html)
* Migrate Load Balancer frontends and DNS records on your production equipments

