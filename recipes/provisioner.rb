# encoding: UTF-8

# Installing provisioning drivers
%w(ssh vagrant aws).each do |driver|
  chef_gem "chef-provisioning-#{driver}" do
    compile_time true if Chef::Resource::ChefGem.method_defined?(:compile_time)
  end
end

chef_gem 'knife-push' do
  compile_time true if Chef::Resource::ChefGem.method_defined?(:compile_time)
end
