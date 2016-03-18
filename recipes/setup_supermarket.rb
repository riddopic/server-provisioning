# encoding: UTF-8

include_recipe 'provisioning::_settings'

# There are two ways to provision the Supermarket Server
#
# 1) Provisioning the entire "provisioning::setup" or
# 2) Just the Chef Server "provisioning::setup_chef_server"
#
# After that you are good to provision Supermarket running:
#   bundle exec chef-client -z -o provisioning::setup_supermarket -E test
#
machine supermarket_server_hostname do
  chef_server lazy { chef_server_config }
  provisioning.specific_machine_options('supermarket').each do |option|
    add_machine_options option
  end
  files lazy {
    {
      "/etc/chef/trusted_certs/#{chef_server_fqdn}.crt" =>
        "#{Chef::Config[:trusted_certs_dir]}/#{chef_server_fqdn}.crt"
    }
  }
  action :converge
end

# Activate Supermarket
ruby_block 'Activate Chef Supermarket' do
  block { activate_supermarket }
end

# Configuring Supermarket on the Chef Server
machine chef_server_hostname do
  provisioning.specific_machine_options('chef-server').each do |option|
    add_machine_options(option)
  end
  recipe 'chef-server-12::supermarket'
  attributes lazy { chef_server_attributes }
  converge true
  action :converge
end

machine_file '/etc/opscode/oc-id-applications/supermarket.json' do
  machine chef_server_hostname
  local_path "#{provisioning_data_dir}/supermarket.json"
  action :download
end

# Installing Supermarket
machine supermarket_server_hostname do
  chef_server lazy { chef_server_config }
  provisioning.specific_machine_options('supermarket').each do |option|
    add_machine_options option
  end
  common_provisioning_recipes.each { |r| recipe r }
  recipe 'provisioning::supermarket'
  attributes lazy { supermarket_config }
  converge true
  action :converge
end

machine_file 'supermarket-server-cert' do
  chef_server lazy { chef_server_config }
  path lazy { "/var/opt/supermarket/ssl/ca/#{supermarket_server_fqdn}.crt" }
  machine supermarket_server_hostname
  local_path lazy {
    "#{Chef::Config[:trusted_certs_dir]}/#{supermarket_server_fqdn}.crt"
  }
  action :download
end

# Add Supermarket Server to the knife.rb config file
template File.join(provisioning_data_dir, 'knife.rb') do
  variables lazy { knife_variables }
end
