# encoding: UTF-8

include_recipe 'provisioning::_settings'

machine jenkins_server_hostname do
  provisioning.specific_machine_options('jenkins-server').each do |option|
    add_machine_options(option)
  end
  recipe 'healthcheck::default'
  converge true
  action :converge
end
