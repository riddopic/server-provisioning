# encoding: UTF-8

default['provisioning'].tap do |provisioning|
  #
  # Provisioning Driver
  provisioning['driver'] = 'vagrant'
  #
  # The Cluster Name which will be use to define all default hostnames
  provisioning['id'] = nil
  #
  # Common Cluster Recipes
  provisioning['common_provisioning_recipes'] = []
  #
  # AWS Driver Attributes.
  provisioning['aws'] = {
    'key_name'               => ENV['USER'],
    'ssh_username'           => nil,
    'security_group_ids'     => nil,
    'image_id'               => nil,
    'subnet_id'              => nil,
    'bootstrap_proxy'        => ENV['HTTPS_PROXY'] || ENV['HTTP_PROXY'],
    'chef_config'            => nil,
    'chef_version'           => nil,
    'use_private_ip_for_ssh' => false
  }
  #
  # SSH Driver Attributes
  provisioning['ssh'] = {
    'key_file'               => nil,
    'prefix'                 => nil,
    'ssh_username'           => nil,
    'bootstrap_proxy'        => ENV['HTTPS_PROXY'] || ENV['HTTP_PROXY'],
    'chef_config'            => nil,
    'chef_version'           => nil,
    'use_private_ip_for_ssh' => false
  }
  #
  # Vagrant Driver Attributes
  provisioning['vagrant'] = {
    'key_file'     => nil,
    'prefix'       => nil,
    'ssh_username' => nil,
    'vm_box'       => nil,
    'image_url'    => nil,
    'vm_memory'    => nil,
    'vm_cpus'      => nil,
    'network'      => nil,
    'chef_config'  => nil,
    'chef_version' => nil
  }
  #
  # Chef Server
  provisioning['chef-server'] = {
    'hostname'         => nil,
    'fqdn'             => nil,
    'organization'     => 'my_enterprise',
    'flavor'           => 't2.medium',
    'existing'         => false,
    'recipes'          => [],
    'attributes'       => {},
    'enable-reporting' => true
  }
  #
  # Chef Analytics Server
  provisioning['analytics'] = {
    'hostname'   => nil,
    'fqdn'       => nil,
    'features'   => 'false',
    'flavor'     => 't2.medium',
    'attributes' => {}
  }
  #
  # Splunk Server
  provisioning['splunk'] = {
    'hostname_prefix' => nil,
    'username'        => 'admin',
    'password'        => nil,
    'flavor'          => 'c3.large'
  }
  #
  # Chef Compliance Server
  provisioning['compliance'] = nil
  #
  # Chef Supermarket Server
  provisioning['supermarket'] = nil
  #
  # Jenkins Server Server
  provisioning['jenkins-server'] = {
    'hostname' => nil,
    'fqdn'     => nil,
    'flavor'   => 't2.medium'
  }
  #
  # Jenkins Workers Server
  provisioning['jenkins-worker'] = {
    'hostname' => nil,
    'fqdn'     => nil,
    'flavor'   => 't2.medium'
  }
end
