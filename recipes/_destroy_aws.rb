# encoding: UTF-8

include_recipe 'server-provisioning::_settings'

aws_security_group 'chef-provisioned-sg' do
  action :destroy
end

aws_route_table 'chef-provisioned-public' do
  action :destroy
end

aws_route_table 'chef-provisioned-route-table' do
  action :destroy
end

aws_vpc 'chef-provisioned-vpc' do
  action :purge
end

aws_dhcp_options 'chef-provisioned-dhcp' do
  action :destroy
end

aws_network_acl 'chef-provisioned-acl' do
  action :destroy
end

aws_subnet 'chef-provisioned-subnet' do
  action :destroy
end
