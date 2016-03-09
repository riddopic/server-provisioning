# encoding: UTF-8

# Installing server-provisioning drivers
%w(ssh vagrant aws).each do |driver|
  chef_gem "chef-provisioning-#{driver}"
end

chef_gem 'knife-push'
