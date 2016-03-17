# encoding: UTF-8

include_recipe 'provisioning::_settings'

begin
  # Setting the chef-zero process
  with_chef_server Chef::Config.chef_server_url

  # Destroy Chef Server
  machine chef_server_hostname do
    action :destroy
  end

  # Delete Trusted Cert
  file File.join(Chef::Config[:trusted_certs_dir], "#{chef_server_fqdn}.crt") do
    action :delete
  end
rescue StandardError
  Chef::Log.warn 'Ouch sorry, I am unable to destroy the Chef Server.'
end
