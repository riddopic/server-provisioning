# encoding: UTF-8

include_recipe 'provisioning::_settings'

# There are two ways to provision the Chef Compliance
#
# 1) Provisioning the entire "provisioning::setup" or
# 2) Just the Chef Server "provisioning::setup_chef_server"
#
# After that you are good to provision Chef Compliance running:
#   bundle exec chef-client -z -o provisioning::setup_compliance -E test
#
machine compliance_server_hostname do
  chef_server lazy { chef_server_config }
  provisioning.specific_machine_options('compliance').each do |option|
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

# Activate Chef Compliance
ruby_block 'Activate Chef Compliance' do
  block { activate_compliance }
end

# Installing Chef Compliance
machine compliance_server_hostname do
  chef_server lazy { chef_server_config }
  provisioning.specific_machine_options('compliance').each do |option|
    add_machine_options option
  end
  recipe 'provisioning::compliance'
  attributes lazy {
    {
      'provisioning' => {
        'compliance' => {
          'fqdn' => compliance_server_fqdn
        }
      }
    }
  }
  converge true
  action :converge
end
