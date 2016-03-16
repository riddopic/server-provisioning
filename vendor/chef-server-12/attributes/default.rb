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

default['chef-server-12']['provisioner_setup'] = true
default['chef-server-12']['store_keys_databag'] = true

# Chef Server Oranization and User
default['chef-server-12']['provisioner'].tap do |provisioner|
  provisioner['ssl']             = true
  provisioner['organization']    = 'chef_provisioner'
  provisioner['org_longname']    = 'Chef Provisioner'
  provisioner['user']            = 'provisioner'
  provisioner['name']            = 'Provisioning'
  provisioner['last_name']       = 'User'
  provisioner['email']           = 'provisioner@example.com'
  provisioner['password']        = 'provisioner'
  provisioner['validator_pem']   = '/tmp/validator.pem'
  provisioner['provisioner_pem'] = '/tmp/provisioner.pem'
  provisioner['databag']         = 'provisioner'
  provisioner['item']            = 'provisioner_pem'
end
