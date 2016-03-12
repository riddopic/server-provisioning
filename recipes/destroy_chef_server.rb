# encoding: UTF-8

# Starting to abstract the specific configurations by providers
include_recipe 'server-provisioning::_settings'

# Setting the chef-zero process
with_chef_server Chef::Config.chef_server_url

# Disassociate the EIP when using the AWS driver
aws_eip_address 'chef-server-eip' do
  action :disassociate
  only_if { provisioning.driver == 'aws' }
end

# Destroy Chef Server
machine chef_server_hostname do
  action :destroy
end

# Delete Trusted Cert
file File.join(Chef::Config[:trusted_certs_dir], "#{chef_server_fqdn}.crt") do
  action :delete
end
