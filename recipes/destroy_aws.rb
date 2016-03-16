# encoding: UTF-8

include_recipe 'provisioning::_settings'

aws_security_group 'ref-sg1' do
  ignore_failure true
  action :destroy
end

aws_route_table 'ref-main-route-table' do
  ignore_failure true
  action :destroy
end

aws_route_table 'ref-public-route' do
  ignore_failure true
  action :destroy
end

aws_route_table 'ref-public-route' do
  ignore_failure true
  action :destroy
end

aws_route_table 'chef-provisioned-route-table' do
  ignore_failure true
  action :destroy
end

aws_vpc 'provisioned-aws-vpc' do
  ignore_failure true
  action :purge
end

aws_dhcp_options 'ref-dhcp-options' do
  ignore_failure true
  action :destroy
end

aws_network_acl 'ref-public-acl' do
  ignore_failure true
  action :destroy
end

aws_subnet 'ref-public-subnet' do
  ignore_failure true
  action :destroy
end

aws_eip_address 'chef-server-eip' do  ignore_failure true
  action :destroy
end

aws_eip_address 'analytics-eip' do
  ignore_failure true
  action :destroy
end

aws_eip_address 'supermarket-eip' do
  ignore_failure true
  action :destroy
end

# aws_route53_hosted_zone 'ksplat.com' do
#   record_sets {
#     aws_route53_record_set 'chef CNAME' do
#       resource_records [chef_server_hostname]
#       rr_name 'chef.ksplat.com'
#       type 'CNAME'
#       ttl 3600
#       action :destroy
#     end
#
#     aws_route53_record_set 'analytics CNAME' do
#       resource_records [analytics_server_hostname]
#       rr_name 'analytics.ksplat.com'
#       type 'CNAME'
#       ttl 3600
#       action :destroy
#     end
#
#     aws_route53_record_set 'supermarket CNAME' do
#       resource_records [supermarket_server_hostname]
#       rr_name 'supermarket.ksplat.com'
#       type 'CNAME'
#       ttl 3600
#       action :destroy
#     end
#   }
# end
