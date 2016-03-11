# encoding: UTF-8

include_recipe 'server-provisioning::_settings'

aws_subnet 'chef-provisioned-subnet' do
  action :destroy
end

aws_security_group 'chef-provisioned-sg' do
  action :destroy
end

aws_vpc 'chef-provisioned-vpc' do
  action :purge
end
