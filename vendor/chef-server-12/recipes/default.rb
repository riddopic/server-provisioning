# encoding: UTF-8

# Configure chef server hostname in /etc/hosts if it isn't there
hostsfile_entry node['ipaddress'] do
  hostname node.hostname
  not_if "grep #{node.hostname} /etc/hosts"
end

directory '/etc/opscode' do
  recursive true
end

chef_ingredient 'chef-server'

template '/etc/opscode/chef-server.rb' do
  owner 'root'
  mode '0644'
  notifies :reconfigure, 'chef_ingredient[chef-server]', :immediately
end

# Install Enabled Plugins
node['chef-server-12']['plugin'].each do |feature, enabled|
  install_plugin(feature) if enabled
end

# Provisioner Setup?
if node['chef-server-12']['provisioner_setup']
  include_recipe 'chef-server-12::provisioner_setup'
end
