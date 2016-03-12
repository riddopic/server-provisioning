# encoding: UTF-8

default['server-provisioning'].tap do |provisioning|
  #
  # Provisioning Driver
  provisioning['driver'] = 'vagrant'
  #
  # AWS Driver Attributes
  provisioning['aws']['key_name'] = ENV['USER']
  provisioning['aws']['ssh_username'] = nil
  provisioning['aws']['security_group_ids'] = nil
  provisioning['aws']['tags'] = { provisioned_by: ENV['USER'] }
  provisioning['aws']['image_id'] = nil
  provisioning['aws']['subnet_id'] = nil
  provisioning['aws']['bootstrap_proxy'] = ENV['HTTPS_PROXY'] || ENV['HTTP_PROXY']
  provisioning['aws']['chef_config'] = nil
  provisioning['aws']['chef_version'] = nil
  provisioning['aws']['use_private_ip_for_ssh'] = false
  #
  # Source IP to add to inbound security group
  provisioning['acl']['source-ips'] = []
  #
  # SSH Driver Attributes
  provisioning['ssh']['key_file'] = nil
  provisioning['ssh']['prefix'] = nil
  provisioning['ssh']['ssh_username'] = nil
  provisioning['ssh']['bootstrap_proxy'] = ENV['HTTPS_PROXY'] || ENV['HTTP_PROXY']
  provisioning['ssh']['chef_config'] = nil
  provisioning['ssh']['chef_version'] = nil
  provisioning['ssh']['use_private_ip_for_ssh']  = false
  #
  # Vagrant Driver Attributes
  provisioning['vagrant']['key_file'] = nil
  provisioning['vagrant']['prefix'] = nil
  provisioning['vagrant']['ssh_username'] = nil
  provisioning['vagrant']['vm_box'] = nil
  provisioning['vagrant']['image_url'] = nil
  provisioning['vagrant']['vm_memory'] = nil
  provisioning['vagrant']['vm_cpus'] = nil
  provisioning['vagrant']['network'] = nil
  provisioning['vagrant']['key_file'] = nil
  provisioning['vagrant']['chef_config'] = nil
  provisioning['vagrant']['chef_version'] = nil
  #
  # The Cluster Name which will be use to define all default hostnames
  provisioning['id'] = nil
  #
  # Common Cluster Recipes
  provisioning['common_provisioning_recipes'] = []
  #
  # Chef Server
  provisioning['chef-server']['hostname'] = nil
  provisioning['chef-server']['fqdn'] = nil
  provisioning['chef-server']['organization'] = 'my_enterprise'
  provisioning['chef-server']['flavor'] = 't2.medium'
  provisioning['chef-server']['existing'] = false
  provisioning['chef-server']['recipes'] = []
  provisioning['chef-server']['attributes'] = {}
  provisioning['chef-server']['enable-reporting'] = true
  #
  # Analytics Server
  provisioning['analytics']['hostname'] = nil
  provisioning['analytics']['fqdn'] = nil
  provisioning['analytics']['features'] = 'false'
  provisioning['analytics']['flavor'] = 't2.medium'
  provisioning['analytics']['attributes'] = {}
  #
  # Supermarket Server
  provisioning['supermarket'] = nil
end
