# Infrastructe part for OpenShift deployment

## 1.Description

These different scripts are Hashicorp Terraform scripts used to deploy all cloud components mandatory as prerequisits before to deploy OpenShift cluster. It take in charge for example the deployment of :  
* VPC  
* Internet Gateway
* Nat Gateway
* Routes table
* Bastion VM
* etc...    

## 2. Prerequisites

- Install Terraform CLI on your workstation **->** [Install Link](https://learn.hashicorp.com/tutorials/terraform/install-cli)

## 3. Deploy all components with Terraform

- Create a ssh key in your OutScale space  

![ssh-key](../docs/ocp-key.png)

- Check Terraform version
```
[root@workstation ~]# terraform version
Terraform v1.2.3
on linux_amd64
```

- Initalize Terraform plugin to download OutScale Plugin
```
[root@workstation 01_ocp_create_network]# terraform init

Initializing the backend...

Initializing provider plugins...
- Finding outscale-dev/outscale versions matching "0.5.3"...
- Installing outscale-dev/outscale v0.5.3...
- Installed outscale-dev/outscale v0.5.3 (signed by a HashiCorp partner, key ID 2EDF9494805B9D61)
```

- Deploy components with Terraform and your OutScale vars.
> :heavy_exclamation_mark: Reserve one IP for VM **ocpinfra01** and put this ip as DNS
```
[root@workstation 01_ocp_create_network]# terraform apply

```