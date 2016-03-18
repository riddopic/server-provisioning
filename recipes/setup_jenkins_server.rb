# encoding: UTF-8

include_recipe 'provisioning::_settings'

machine jenkins_server_hostname do
  chef_server lazy { chef_server_config }
  provisioning.specific_machine_options('jenkins-server').each do |option|
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

machine jenkins_server_hostname do
  chef_server lazy { chef_server_config }
  provisioning.specific_machine_options('jenkins-server').each do |option|
    add_machine_options option
  end
  common_cluster_recipes.each { |r| recipe r }
  # recipe 'healthcheck::default'
  converge true
  action :converge
end
