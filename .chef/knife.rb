# encoding: UTF-8

current_dir = File.dirname(__FILE__)
chef_repo_path "#{current_dir}/.."
node_name 'delivery'
file_cache_path File.join(current_dir, 'local-mode-cache', 'cache')

if defined? ::Chef::Config
  provisioning_knife = File.join(current_dir, 'provisioning-data', 'knife.rb')
  Chef::Config.from_file(provisioning_knife) if File.exist?(provisioning_knife)
end

cookbook_path "#{current_dir}/../cookbooks"
chef_zero.port 8890
