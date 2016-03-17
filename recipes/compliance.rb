# encoding: UTF-8

directory '/etc/chef-compliance' do
  recursive true
end

chef_ingredient 'compliance' do
  config "fqdn '#{node['provisioning']['compliance']['fqdn']}'"
  action [:install, :reconfigure]
end

ingredient_config 'compliance' do
  action :render
  notifies :reconfigure, 'chef_ingredient[compliance]'
end

omnibus_service 'compliance/nginx'
