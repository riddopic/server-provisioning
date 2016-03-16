# `provisioning`

This cookbook can generate a Chef Infrastructure Provisioning Environment using a minimal CentOS or Ubuntu image. This cookbook will setup a Chef server and related components and includes:

*  1 - Chef Server 12
*  1 - Supermarket Server
*  1 - Chef Analytics Server

Rake Help
------------
The `Rakefile` will help you use Chef Infrastructure Provisioning Cookbook! Give it a try:

```
$ rake

Chef Infrastructure Provisioning Environment Helper

Setup Tasks
The following tasks should be used to set up your environment
rake setup:analytics      # Activate Analytics Server
rake setup:chef_server    # Setup a Chef Server
rake setup:cluster        # Setup the Chef Infrastructure Provisioning Environment
rake setup:generate_env   # Generate a Chef Infrastructure Provisioning Environment
rake setup:prerequisites  # Install all the prerequisites on you system
rake setup:supermarket    # Create a Supermarket Server

Maintenance Tasks
The following tasks should be used to maintain your environment
rake maintenance:clean_cache  # Clean the cache
rake maintenance:update       # Update cookbook dependencies

Destroy Tasks
The following tasks should be used to destroy your environment
rake destroy:all          # Destroy Everything
rake destroy:analytics    # Destroy Analytics Server
rake destroy:chef_server  # Destroy Chef Server
rake destroy:supermarket  # Destroy Supermarket Server

Cluster Information
The following tasks should be used to get information about your environment
rake info:list_core_services  # List nodes in the Chef Infrastructure Provisioning Environment

To switch your environment run:
  # export CHEF_ENV=my_environment_name
```

## Easy Setup

The easiest way to setup your Chef infrastructure is to follow these steps:

#### 1) Install and Configure ChefDK

Follow the instructions at https://docs.chef.io/install_dk.html to install and configure ChefDK as your default version of ruby.

#### 2) Create an environment

Generate an environment file using the following command

```
$ rake setup:generate_env
```

You can accept the default options by pressing `<enter>`.

Remember to export your environment by running: `export CHEF_ENV=my_environment_name`

#### 3) Provision your Infrastructure

```
$ rake setup:cluster
```

#### Access to the Infrastructure

Once you have should have the Infrastructure up and running you can use the `info:list_core_services`

#### Provision a Supermarket Server

You can provision a private Supermarket instance to store and resolve cookbook
dependencies. To create one for your environment with the following command:

```
$ rake setup:supermarket
```

#### Provision an Analytics Server

Once you have completed the `cluster` provisioning, you could setup an Analytics Server by running:

```
$ rake setup:analytics
```

That will provision and activate Analytics on your entire cluster.

# Available Provisioning Methods

This cookbook uses [chef-provisioning](https://github.com/chef/chef-provisioning) to manipulate the infrastructure acting as the orchestrator, it uses the default driver `vagrant` but you can switch drivers by modifying the attribute `['provisioning']['driver']`

The available drivers that you can use are:

### Vagrant Driver [Default]
This driver will provision the Provisioner cluster locally using [Vagrant](https://www.vagrantup.com/).
As such, you MUST have vagrant installed for this to function.

The `rake setup:generate_env` task will generate this for you.

If you edit this config by hand, you MUST provide:

1. `vm_memory` and `vm_cpus`.
2. `vm_box`.
3. `network` configuration.

Here is an example of the environment file using the vagrant driver.

```json
{
  "name": "test",
  "description": "Chef Infrastructure Provisioning Environment",
  "json_class": "Chef::Environment",
  "chef_type": "environment",
  "override_attributes": {
    "provisioning": {
      "id": "test",
      "driver": "vagrant",
      "vagrant": {
        "ssh_username": "vagrant",
        "key_file": "/Users/sharding/.vagrant.d/insecure_private_key",
        "vm_box": "opscode-centos-6.6",
        "image_url": "https://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_centos-6.6_chef-provisionerless.box",
        "use_private_ip_for_ssh": true
      },
      "chef-server": {
        "organization": "test",
        "existing": false,
        "vm_hostname": "chef.example.com",
        "network": ":private_network, {ip: '33.33.33.10'}",
        "vm_memory": "2048",
        "vm_cpus": "2"
      },
      "analytics": {
        "vm_hostname": "analytics.example.com",
        "network": ":private_network, {ip: '33.33.33.11'}",
        "vm_memory": "2048",
        "vm_cpus": "2"
      },
      "supermarket": {
        "vm_hostname": "supermarket.example.com",
        "network": ":private_network, {ip: '33.33.33.12'}",
        "vm_memory": "2048",
        "vm_cpus": "2"
      },
    }
  }
}
```

### AWS Driver

This driver will provision the infrastructure in Amazon Ec2.

You MUST configure your `~/.aws/config` file like this:

```
$ vi ~/.aws/config
[default]
region = us-west-2
aws_access_key_id = YOUR_ACCESS_KEY_ID
aws_secret_access_key = YOUR_SECRET_KEY
```

This cookbook will also create a `security-group` with the following ports open from the KP NAT interface:

| Port           | Protocol    | Description                                 |
| -------------- |------------ | ------------------------------------------- |
| 10000 - 10003  | TCP | Push Jobs
| 8989           | TCP | Provisioner Git (SCM)
| 443            | TCP | HTTP Secure
| 22             | TCP | SSH
| 80             | TCP | HTTP
| 5672           | TCP | Analytics MQ
| 10012 - 10013  | TCP | Analytics Messages/Notifier

The list of attributes that you have available are:

| Attribute                | Description                                 |
| ------------------------ | ------------------------------------------- |
| `key_name`               | Key Pair to configure.                      |
| `ssh_username`           | SSH username to use to connect to machines. |
| `chef_version`           | The chef version to install on the machine. |
| `chef_config`            | Anything you want dumped in `/etc/chef/client.rb` |
| `image_id`               | AWS AMI.                                    |
| `flavor`                 | Size/flavor of your machine.                |
| `aws_tags`               | Hash of aws tags to add to an specific component. |
| `security_group_ids`     | Security Group on AWS.                      |
| `bootstrap_proxy`        | Automatically configure HTTPS proxy. |
| `install_sh_path`        | Installation path of the shell script to install chef.|
| `use_private_ip_for_ssh` | Set to `true` if you want to use the private  ipaddress.|


Here is an example of how you specify them

```json
{
  "name": "aws",
  "description": "Chef Infrastructure Provisioning Environment",
  "json_class": "Chef::Environment",
  "chef_type": "environment",
  "override_attributes": {
    "provisioning": {
      "id": "aws",
      "driver": "aws",
      "aws": {
        "key_name": "yourkey",
        "ssh_username": "ubuntu",
        "image_id": "ami-a52bc9c5",
        "subnet_id": "chef-provisioned-subnet",
        "security_group_ids": "chef-provisioned-sg",
        "use_private_ip_for_ssh": false
      },
      "acl": {
        "source-ips": [
          "54.53.128.100/32",
          "45.35.100.128/32",
        ]
      },
      "chef-server": {
        "organization": "chefops",
        "flavor": "m3.medium"
      },
      "analytics": {
        "flavor": "c3.xlarge"
      },
      "supermarket": {
        "flavor": "c3.xlarge"
      }
    }
  }
}
```

### SSH Driver

This driver will NOT provision any infrastructure. It assumes you have already provisioned the machines and it will manipulate then to install and configure the your Chef infrastructure".

You have to provide:

1. Ip address or Hostname for all your machine resources.
2. Username
3. Either `key_file` or `password`

The list of attributes that you have available are:

| Attribute                | Description                                 |
| ------------------------ | ------------------------------------------- |
| `ssh_username`           | SSH username to use to connect to machines. |
| `chef_config`            | Anything you want dumped in `/etc/chef/client.rb` |
| `chef_version`           | The chef version to install on the machine. |
| `key_file`               | The SSH Key to use to connect to the machines.   |
| `password`               | The password to use to connect to the machines.  |
| `prefix`                 | Prefix to add at the beginning of any ssh-command.|
| `bootstrap_proxy`        | Automatically configure HTTPS proxy. |
| `install_sh_path`        | Installation path of the shell script to install chef.|
| `use_private_ip_for_ssh` | Set to `true` if you want to use the private  ipaddress. |

This is an example of how to specify this information

```json
{
"name": "ssh",
  "description": "",
  "description": "Chef Infrastructure Provisioning Environment",
  "chef_type": "environment",
  "override_attributes": {
    "provisioning": {
      "id": "ssh",
      "driver": "ssh",
      "ssh": {
        "ssh_username": "ubuntu",
        "prefix": "echo myPassword | sudo -S ",
        "key_file": "~/.ssh/id_rsa.pem",
        "bootstrap_proxy": "GATEWAY_MACHINE",
      },
      "chef-server": {
        "ip": "33.33.33.10",
        "organization": "ssh",
        "provisioner_password": "SuperSecurePassword"
      },
      "analytics": {
        "ip": "33.33.33.12"
      },
      "supermarket": {
        "ip": "33.33.33.17"
      }
    }
  }
}

```

# Global Attributes

### common_cluster_recipes

Add any recipe that you need to add to the run_list of all the servers in the cluster.

As an example:
* We would like to aply a security policy to every single server on the cluster.

  `security_policies::lock_root_login` locks down root login

This attribute would look like:

```
default['provisioning']['common_cluster_recipes'] = ['security_policies::lock_root_login']
```

# Specific Attributes per Component

There are additional specific attributes per component that you can use to configure your cluster
in different ways.

### Chef Server Settings

| Attribute       | Description                       |
| --------------- | --------------------------------- |
| `hostname`      | Hostname of your Chef Server.     |
| `organization`  | The organization name we will create for the Provisioner Environment. |
| `flavor`        | AWS Flavor of the Chef Server.   |
| `fqdn`          | The Chef Server FQDN to substitute the IP Address. |
| `existing`      | Set this to `true` if you want to use an existing chef-server. |
| `recipes`       | Additional recipes to run on your Chef Server. |
| `provisioning_password` | Password of the Provisioning User on the Chef Server. |

### Analytics Settings

| Attribute       | Description                       |
| --------------- | --------------------------------- |
| `hostname`      | Hostname of your Analytics Server.|
| `fqdn`          | The Analytics FQDN to use for the `/etc/opscode-analytics/opscode-analytics.rb`. |
| `flavor`        | AWS Flavor of the Analytics Server.|
| `ip`            | [SSH Driver] Ip Address of the Analytics Server.|
| `host`          | [SSH Driver] Hostname of the Analytics Server.|

### Supermarket Settings

| Attribute       | Description                       |
| --------------- | --------------------------------- |
| `hostname`      | Hostname of your Supermarket Server.|
| `fqdn`          | The Supermarket FQDN to use. Although Supermarket will consume it from `node['fqdn']` |
| `flavor`        | AWS Flavor of the Supermarket Server.|
| `ip`            | [SSH Driver] Ip Address of the Supermarket Server.|
| `host`          | [SSH Driver] Hostname of the Supermarket Server.|

# Supported Platforms


* Enterprise Linux (CentOS, RHEL) 6, 7 64-bit
* Ubuntu 14.04 64-bit
