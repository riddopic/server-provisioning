# encoding: UTF-8

default['chef-server-12']['version'] = 'latest'

# Plugins and Feautures
#
# Install Chef Server plugins by setting the value to `true`.
# If there is more plugins you just need to add them as follow:
# default['chef-server-12']['plugin']['PLUGIN_NAME'] = true
default['chef-server-12']['plugin']['manage'] = true
default['chef-server-12']['plugin']['reporting'] = true
default['chef-server-12']['plugin']['push-server'] = true
default['chef-server-12']['plugin']['chef-sync'] = false

# Chef Server Parameters
default['chef-server-12']['api_fqdn'] = node['ipaddress']
default['chef-server-12']['topology'] = 'standalone'
default['chef-server-12']['extra_config'] = nil

# Analytics Server Parameters
default['chef-server-12']['analytics'] = nil

# Supermarket Server Parameters
default['chef-server-12']['supermarket'] = nil

# Chef Server Oranization and User
default['chef-server-12']['delivery_setup'] = true
default['chef-server-12']['store_keys_databag'] = true
default['chef-server-12']['delivery']['ssl'] = true
default['chef-server-12']['delivery']['organization'] = 'chef_delivery'
default['chef-server-12']['delivery']['org_longname'] = 'ChefDev Chops'
default['chef-server-12']['delivery']['user'] = 'delivery'
default['chef-server-12']['delivery']['name'] = 'Delivery'
default['chef-server-12']['delivery']['last_name'] = 'User'
default['chef-server-12']['delivery']['email'] = 'delivery@getchef.com'
default['chef-server-12']['delivery']['password'] = 'delivery'
default['chef-server-12']['delivery']['validator_pem'] = '/tmp/validator.pem'
default['chef-server-12']['delivery']['delivery_pem'] = '/tmp/delivery.pem'
default['chef-server-12']['delivery']['db'] = 'delivery'
default['chef-server-12']['delivery']['item'] = 'delivery_pem'
