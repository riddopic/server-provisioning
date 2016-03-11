chef-server-12 Cookbook
===============================

This cookbook install and maintain a Chef Server v12.

Additionally it can setup the initial configuration for Provisioner.

Prerequisits
-----
This cookbook need an secret key to be able to handle the PEM key
in secure mode. If you are using Test Kitchen the key already exist.

If you want to regenerate the existing key run:
```
$ openssl rand -base64 512 > test/integration/default/encrypted_data_bag_secret
```
If you are using `chef-solo` you have to manually create the secret key and
configure `solo.rb`.

Platform
-----
Chef Server v12 packages are available for the following platforms:

* Redhat 6.5 64-bit
* Centos 6.5 64-bit
* Ubuntu 12.04, 12.10 64-bit

Usage Solo Mode
-----
This cookbook can be used on `solo` mode to spinup a Chef Server v12.

Steps:

- Transfer this cookbook to the node and ensure that it has chef installed. `/etc/chef/cookbooks/chef-server-12`
- Create a secret key. (Only if you need the Provisioner Setup Process)

```
    # openssl rand -base64 512 > /etc/chef/encrypted_data_bag_secret
```
- Configure `/etc/chef/solo.rb`
```
cookbook_path "/etc/chef/cookbooks"
encrypted_data_bag_secret "/etc/chef/encrypted_data_bag_secret"
http_proxy ENV['http_proxy']
https_proxy ENV['https_proxy']
```
- Create a `/etc/chef/dna.json`
```
{
  "run_list" : ["chef-server-12::default"],

  /* This will override the default api_fqdn attribute from the cookbook */
  /* Use it only if you have multiple ip addresses or if you want to set */
  /* the hostname/FQDN on it. */

  "chef-server-12" : {
    "api_fqdn":"ANOTHER_IP_ADDRESS"
  }
}
```
- Run `chef-solo`
```
    # chef-solo --config /etc/chef/solo.rb --json-attributes /etc/chef/dna.json --log_level info
```

Usage Test-Kitchen Mode
-----
You basically need to run:

    kitchen converge [PLATFORM_YOU_WANT]
