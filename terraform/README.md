
# `chef-provisioned-vpc`

A Terraform plan to setup the Network Infrastructure used by Chef Provisioning.

# Usage

##### 1) Install and Configure ChefDK

Follow the instructions at https://docs.chef.io/install_dk.html to install and configure chefdk as your default version of ruby.

##### 2) Install Terraform

Downloads are here: https://www.terraform.io/downloads.html . Place in your path for direct execution.

##### 3) Create and populate `terraform.tfvars` at the root of the repository

```
# Terraform Variables File for Corriere
#
aws_access_key_id        = "<KEY>"
aws_secret_access_key    = "<SECRET>"
aws_default_region       = "us-west-2"
aws_key_pair_name        = "<KEY-PAIR-NAME>"
```

##### 4) Store your key-pair pem file inside `.keys/`

##### 5) Load the Terraform Modules and apply the Plan

```
$ terraform plan
$ terraform apply
```

The output of the process will be similar to this:

```
Apply complete! Resources: 74 added, 0 changed, 0 destroyed.

The state of your infrastructure has been saved to the path
below. This state is required to modify and destroy your
infrastructure, so keep it safe. To inspect the complete state
use the `terraform show` command.

State path: terraform.tfstate

Outputs:

  F5 SSH Address:   = ssh admin@ec2-52-35-238-159.us-west-2.compute.amazonaws.com
  F5 HTTP URL:      = https://ec2-52-35-238-159.us-west-2.compute.amazonaws.com
  SSH Bastion Host: = ec2-52-11-46-142.us-west-2.compute.amazonaws.com
```
