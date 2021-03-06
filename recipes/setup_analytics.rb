# encoding: UTF-8

include_recipe 'provisioning::_settings'

# There are two ways to provision the Analytics Server
#
# 1) Provisioning the entire "provisioning::setup" or
# 2) Just the Chef Server "provisioning::setup_chef_server"
#
# After that you are good to provision Analytics running:
#   bundle exec chef-client -z -o provisioning::setup_analytics -E test
#
machine analytics_server_hostname do
  chef_server lazy { chef_server_config }
  provisioning.specific_machine_options('analytics').each do |option|
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

# Activate Chef Analytics
ruby_block 'Activate Chef Analytics' do
  block { activate_analytics }
end

# Configuring Analytics on the Chef Server
machine chef_server_hostname do
  provisioning.specific_machine_options('chef-server').each do |option|
    add_machine_options(option)
  end
  recipe 'chef-server-12::analytics'
  attributes lazy { chef_server_attributes }
  converge true
  action :converge
end

%w(actions-source.json webui_priv.pem).each do |analytics_file|
  machine_file "/etc/opscode-analytics/#{analytics_file}" do
    machine chef_server_hostname
    local_path "#{provisioning_data_dir}/#{analytics_file}"
    action :download
  end
end

# Installing Analytics
machine analytics_server_hostname do
  chef_server lazy { chef_server_config }
  provisioning.specific_machine_options('analytics').each do |option|
    add_machine_options option
  end
  recipe 'provisioning::analytics'
  files(
    '/etc/opscode-analytics/actions-source.json' =>
      "#{provisioning_data_dir}/actions-source.json",
    '/etc/opscode-analytics/webui_priv.pem' =>
      "#{provisioning_data_dir}/webui_priv.pem"
  )
  attributes lazy {
    {
      'provisioning' => {
        'analytics' => {
          'fqdn' => analytics_server_fqdn,
          'features' => 'false'
        }
      }
    }
  }
  converge true
  action :converge
end

machine_file 'analytics-server-cert' do
  chef_server lazy { chef_server_config }
  path lazy { "/var/opt/opscode-analytics/ssl/ca/#{analytics_server_fqdn}.crt" }
  machine analytics_server_hostname
  local_path lazy {
    "#{Chef::Config[:trusted_certs_dir]}/#{analytics_server_fqdn}.crt"
  }
  action :download
end

# Add Analytics Server to the knife.rb config file
template File.join(provisioning_data_dir, 'knife.rb') do
  variables lazy { knife_variables }
end
