
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

The ouput of the process will be similar to this:

```
Apply complete! Resources: 64 added, 0 changed, 0 destroyed.

The state of your infrastructure has been saved to the path
below. This state is required to modify and destroy your
infrastructure, so keep it safe. To inspect the complete state
use the `terraform show` command.

State path: terraform.tfstate

Outputs:

  chef-analytics_security_group_id  = sg-9540def2
  chef-compliance_security_group_id = sg-9240def5
  chef-server_security_group_id     = sg-9640def1
  jenkins-worker_security_group_id  = sg-9440def3
  us-west-2b-public                 = subnet-782fec1c
  vpc_id                            = vpc-a826decc
```