# OCP Install automation with Ansible

## 1. Description

All this code permits you to deploy an OCP cluster on 3DS Outscale automatically with Ansible. You have the possibility to set your parameters to adapt your cluster to your needs (number of nodes, cpu, memory, disk, etc...).

To give you an estimate, a cluster with 6 worker nodes takes around 30 - 40 min to be up and running from scratch with this automation (depending your Internet connection)

## 2. Architecture
 
 ![Schema](../docs/ocp-3ds-outscale.svg)


## 3. What this automation do

* Deploy an infrastructure VM with :
	- A DNS server with all needed records for your OCP cluster (api, api-int, *.apps, etc...)
	- A Load Balancer based on HAProxy as endpoint for the OCP cluster with 4 frontends

* Deploy a temporary OCP bootstrap node to install your cluster. This node will be deleted at the end of this automation.

* Deploy 3 OCP master nodes.

* Deploy x OCP worker nodes as requested by the user.

* Deploy GitOps (ArgoCD) on your OCP cluster if you requested it in vars file

## 4. Deployment

✅ **Please read the entire documentation step by step to deploy without error**

> :heavy_exclamation_mark: All steps must be done on your bastion VM (**ocpbastion01**) deploy by step02 connected to the Internet (to pull image). 

**1. Connect to your bastion VM (ocpbastion01) via its EIP**
```
ssh -i .ssh/outscale fedora@171.33.114.187
Last login: Tue Jun 21 13:16:30 2022 from 212.157.222.2
[fedora@ip-192-168-1-167 ~]$
```

**2. Install tools and utilities on your bastion VM**
```
[fedora@ip-192-168-1-167 ~]$ sudo dnf install git vim bind-utils jq podman python3-pip
```

**3. Install ansible-navigator (https://ansible-navigator.readthedocs.io/en/latest/installation/)**
```
[fedora@ip-192-168-1-167 ~]$ sudo python3 -m pip install ansible-navigator --user
[fedora@ip-192-168-1-167 ~]$ sudo -i
[root@ip-192-168-1-167 ~]# echo 'export PATH=$HOME/.local/bin:$PATH' >> ~/.profile
[root@ip-192-168-1-167 ~]# source ~/.profile
[root@ip-192-168-1-167 ~]# ansible-navigator --version
ansible-navigator 2.1.0
```

**4. Pull Ansible EE with all embedded tools on your bastion VM**
```
[root@ip-192-168-1-167 ~]# podman pull quay.io/david_martini/ocp_outscale:4.10
[root@ip-192-168-1-167 ~]# podman images
REPOSITORY                          TAG         IMAGE ID      CREATED       SIZE
quay.io/david_martini/ocp_outscale  4.10        4d5921236f9e  2 months ago  1.63 GB
```

**5. Clone GIT repository on your bastion VM**
```
[root@ip-192-168-1-167 ~]# git clone https://github.com/davmartini/ocp_outscale.git
```

**6. Generate SSH Key to access to your OCP nodes. This Key will be needed to complete vars file in next step**
```
[root@ip-192-168-1-167 ~]# ssh-keygen -t rsa
Generating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa): /root/.ssh/ocpnode   
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /root/.ssh/ocpnode
Your public key has been saved in /root/.ssh/ocpnode.pub
The key fingerprint is:
SHA256:UExItD9yVgoiiBuCyA55QXvO1FM22nPtg197JtJJrVk root@ip-192-168-1-4.ocpoutscale.local
The key's randomart image is:
+---[RSA 3072]----+
| .o  oo+*        |
|=o o ..B.. .     |
|X.+ + B o o .    |
|++ * . = = o   . |
|..  o . S . o o E|
|       + . . = * |
|            o B o|
|             . + |
|                 |
+----[SHA256]-----+
```

**7. Go to GIT workspace and edit vars file with your configuration**
```
[root@ip-192-168-1-167 ~]# cd $PATH/ocp_outscale/03_ocp_install/
[root@ip-192-168-1-167 ~]# vim ansible/vars/vars.yaml
```

**8. Deploy your cluster with Ansible**
> :heavy_exclamation_mark: Before to deploy your cluster, be sure your have configured **ocpinfra01** VM as first DNS server in your DHCP option.
```
ansible-navigator run ansible/main.yml -i ansible/inventory --eei quay.io/david_martini/ocp_outscale:4.10 -m stdout --pae false --lf /tmp/ansible-navigator.log
```

**9. Cluster information**

A the end of automatic deployment, all needed information to connet to your cluster will be printed (kubeconfig, URL, kubeadmin-passowrd). 
> :heavy_exclamation_mark: Be sure to save these informations. If you lose them, you couldn't connect to your cluster and you will have no possibility to recover them

## 7. Access to your custer from Mac OSX
You can access to you fresh installed cluster from your remote computer to define send all requests to infravm EIP.

* Install dnsmasq
```
brew install dnsmasq
```

* Show dnsmasq version
```
brew info dnsmasq
```

* Modify dnsmasq config file
```
vim /usr/local/etc/dnsmasq.conf
conf-file=/Users/dmartini/.dnsmasq/dnsmasq.conf
```

* Create new config file
```
vim /Users/dmartini/.dnsmasq/dnsmasq.conf
# *.ocpoutscale.local wildcard will be resolved as 127.0.0.1, including subdomains where 171.33.93.77 is infravm EIP
address=/*.ocpoutscale.local/171.33.93.77 
listen-address=127.0.0.1
```

* Restart dnsmasq
```
sudo brew services restart dnsmasq
```

* Add 127.0.0.1 as your first dns server in your Mac OSX network configuration


## 8. More information

* You can check needed variables with **vars.yaml.example** example.
* You have access to HAProxy stats for each frontend on the URL : http://${Infra VM IP}:5000/stats. You will need to set a stats password in the vars file.
* To access your cluster from a remote computer, you have to add infravm IP as DNS server in your own network configuration.

## 9. Day 2 operation

* Enable a container registry for your OpenShift Cluster: [Registry configuration](https://docs.openshift.com/container-platform/4.10/installing/installing_platform_agnostic/installing-platform-agnostic.html#installation-registry-storage-config_installing-platform-agnostic)
* Configure persistent storage for Monitoring stack: [Monitoring configuration](https://docs.openshift.com/container-platform/4.10/monitoring/configuring-the-monitoring-stack.html#configuring-persistent-storage)
* Enable authentification provider: [Auth configuration](https://docs.openshift.com/container-platform/4.10/authentication/understanding-authentication.html)
* Migrate Load Balancer frontends and DNS records on your production equipments
