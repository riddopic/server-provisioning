# encoding: UTF-8

include_recipe 'provisioning::_settings'

begin
  with_chef_server chef_server_url,
    client_name: 'provisioner',
    signing_key_filename: "#{provisioning_data_dir}/provisioner.pem"

  # Kill the machine
  machine jenkins_worker_hostname do
    ignore_failure true
    action :destroy
  end
rescue StandardError => e
  Chef::Log.warn("We can't destroy the Jenkins Worker: #{e.message}")
end

