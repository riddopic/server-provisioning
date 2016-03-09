# encoding: UTF-8

hostsfile_entry node['ipaddress'] do
  hostname node.hostname
  not_if "grep #{node.hostname} /etc/hosts"
end

ingredient_config 'supermarket' do
  config JSON.pretty_generate(node['supermarket-config'])
  action :add
end

chef_ingredient 'supermarket' do
  action [:install, :reconfigure]
end
