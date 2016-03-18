# encoding: UTF-8

# Installing provisioning drivers
%w(ssh vagrant aws).each do |driver|
  chef_gem "chef-provisioning-#{driver}" do
    compile_time true if Chef::Resource::ChefGem.method_defined?(:compile_time)
  end
end

%w(knife-push knife-analytics).each do |knife_plugin|
  chef_gem knife_plugin do
    compile_time true if Chef::Resource::ChefGem.method_defined?(:compile_time)
  end
end

chef_gem 'aws-sdk' do
  compile_time true if Chef::Resource::ChefGem.method_defined?(:compile_time)
end
