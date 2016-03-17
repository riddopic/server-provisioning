# encoding: UTF-8

include_recipe 'provisioning::_settings'

# Provision the Chef Server with an empty runlist, extract the primary ipaddress
# to use as the hostname in the initial `/etc/opscode/chef-server.rb` file.
#
machine chef_server_hostname do
  provisioning.specific_machine_options('chef-server').each do |option|
    add_machine_options(option)
  end
  action :converge
end

aws_eip_address 'chef-server-eip' do
  machine chef_server_hostname
  associate_to_vpc true
end

machine chef_server_hostname do
  Dir.glob("#{Chef::Config[:trusted_certs_dir]}/*").each do |cert|
    file ::File.join('/etc/chef/trusted_certs', ::File.basename(cert)), cert
  end
  action :converge
end

directory provisioning_data_dir do
  recursive true
  action :create
end

# The password of the provisioning user
file "#{provisioning_data_dir}/provisioning_password" do
  mode 00644
  content provisioning_password
  sensitive true
  action :create
end

# Now that we've extracted the Chef Server's ipaddress we can fully
# converge and complete the install.
machine chef_server_hostname do
  provisioning.specific_machine_options('chef-server').each do |option|
    add_machine_options(option)
  end
  common_provisioning_recipes.each { |r| recipe r }
  if node['provisioning']['chef-server']['existing']
    recipe 'chef-server-12::provisioning_setup'
  else
    recipe 'chef-server-12'
  end
  node['provisioning']['chef-server']['recipes'].each { |r| recipe r }
  attributes lazy { chef_server_attributes }
  converge true
  action :converge
end

directory Chef::Config[:trusted_certs_dir] do
  action :create
end

machine_file 'chef-server-cert' do
  machine chef_server_hostname
  path lazy { "/var/opt/opscode/nginx/ca/#{chef_server_fqdn}.crt" }
  local_path lazy {
    "#{Chef::Config[:trusted_certs_dir]}/#{chef_server_fqdn}.crt"
  }
  action :download
end

# Fetch our client and validator pems from the provisioned Chef Server
machine_file '/tmp/validator.pem' do
  machine chef_server_hostname
  local_path "#{provisioning_data_dir}/validator.pem"
  action :download
end

machine_file '/tmp/provisioner.pem' do
  machine chef_server_hostname
  mode '0644' # This is not working.
  local_path "#{provisioning_data_dir}/provisioner.pem"
  action :download
end

# Workaround: Ensure that the "provisioner.pem" has the right permissions.
# PR: https://github.com/chef/provisioning/issues/174
file "#{provisioning_data_dir}/provisioner.pem" do
  mode 00644
end

# Generate a knife config file that points at the new Chef Server
template File.join(provisioning_data_dir, 'knife.rb') do
  variables lazy { knife_variables }
end

ruby_block 'upload cookbook dependencies' do
  block do
    require 'chef/knife/cookbook_upload'
    Chef::Config.from_file(File.join(provisioning_data_dir, 'knife.rb'))
    Chef::Knife::CookbookUpload.load_deps
    knife = Chef::Knife::CookbookUpload.new
    knife.config[:cookbook_path] = Chef::Config[:cookbook_path]
    knife.config[:all] = true
    knife.config[:force] = true
    knife.run
  end
end
