# encoding: UTF-8

include_recipe 'provisioning::_settings'

# If Chef Compliance is enabled
if compliance_enabled?
  begin
    # Setting the new Chef Server we just created
    with_chef_server chef_server_url,
      client_name: 'provisioner',
      signing_key_filename: "#{provisioning_data_dir}/provisioner.pem"

    # Destroy Chef Compliance Server
    machine compliance_server_hostname do
      action :destroy
    end

    # Delete Trusted Cert
    file File.join(Chef::Config[:trusted_certs_dir], "#{compliance_server_fqdn}.crt") do
      action :delete
    end

    # Delete the lock file
    File.delete(compliance_lock_file)
  rescue StandardError => e
    Chef::Log.warn("We can't proceed to destroy the Chef Compliance Server.")
    Chef::Log.warn("We couldn't get the chef-server Public IP: #{e.message}")
  end
else
  Chef::Log.warn('You must provision an Chef Compliance Server before be able')
  Chef::Log.warn('to destroy it. READ => recipe/setup_compliance.rb')
end
