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

- Initalize Terraform plugin to download OutScale Plugin
```
[root@workstation ~]# terraform version
Terraform v1.2.3
on linux_amd64
```