# encoding: UTF-8

include_recipe 'provisioning::_settings'

# If Supermarket is enabled
if supermarket_enabled?
  begin
    # Setting the new Chef Server we just created
    with_chef_server chef_server_url,
      client_name: 'provisioner',
      signing_key_filename: "#{provisioning_data_dir}/provisioner.pem"

    # Destroy Supermarket Server
    machine supermarket_server_hostname do
      action :destroy
    end

    # Delete Trusted Cert
    file File.join(Chef::Config[:trusted_certs_dir], "#{supermarket_server_fqdn}.crt") do
      action :delete
    end

    # Delete the lock file
    File.delete(supermarket_lock_file)
  rescue StandardError => e
    Chef::Log.warn("We can't proceed to destroy the Supermarket Server.")
    Chef::Log.warn("We couldn't get the chef-server Public IP: #{e.message}")
  end
else
  Chef::Log.warn('You must provision an Supermarket Server before be able to')
  Chef::Log.warn('destroy it. READ => recipe/setup_supermarket.rb')
end
