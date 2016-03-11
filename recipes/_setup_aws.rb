# encoding: UTF-8

include_recipe 'server-provisioning::_settings'

aws_dhcp_options 'chef-provisioned-dhcp' do
  aws_tags chef_type: 'aws_dhcp_options'
end

aws_vpc 'chef-provisioned-vpc' do
  cidr_block '172.16.0.0/24'
  internet_gateway true
  instance_tenancy :default
  main_routes '0.0.0.0/0' => :internet_gateway
  dhcp_options 'chef-provisioned-dhcp'
  enable_dns_support true
  enable_dns_hostnames true
  aws_tags chef_type: 'aws_vpc'
end

aws_route_table 'chef-provisioned-main-route-table' do
  vpc 'chef-provisioned-vpc'
  routes '0.0.0.0/0' => :internet_gateway
  aws_tags chef_type: 'aws_route_table'
end

aws_vpc 'chef-provisioned-vpc' do
  main_route_table 'chef-provisioned-main-route-table'
end

aws_network_acl 'chef-provisioned-acl' do
  vpc 'chef-provisioned-vpc'
  inbound_rules [
    {
      rule_number: 100,
      action: :allow,
      protocol: -1,
      cidr_block: '0.0.0.0/0'
    },
    {
      rule_number: 200,
      action: :allow,
      protocol: 6,
      port_range: 443..443,
      cidr_block: '172.31.0.0/24'
    }
  ]
  outbound_rules [
    {
      rule_number: 100,
      action: :allow,
      protocol: -1,
      cidr_block: '0.0.0.0/0'
    }
  ]
end

aws_security_group 'chef-provisioned-sg' do
  inbound_rules [
    { # SSH
      port: 22,
      protocol: :tcp,
      sources: node['server-provisioning']['acl']['source-ips']
    },
    { # HTTP
      port: 80,
      protocol: :tcp,
      sources: node['server-provisioning']['acl']['source-ips']
    },
    { # HTTPS
      port: 443,
      protocol: :tcp,
      sources: node['server-provisioning']['acl']['source-ips']
    },
    { # Git (SCM)
      port: 8989,
      protocol: :tcp,
      sources: node['server-provisioning']['acl']['source-ips']
    },
    { # Analytics MQ
      port: 5672,
      protocol: :tcp,
      sources: node['server-provisioning']['acl']['source-ips']
    },
    { # Push Jobs
      port: 10000..10003,
      protocol: :tcp,
      sources: node['server-provisioning']['acl']['source-ips']
    },
    { # Analytics Messages/Notifier
      port: 10012..10013,
      protocol: :tcp,
      sources: node['server-provisioning']['acl']['source-ips']
    }
  ]
  outbound_rules [
    { port: 0..65535, destinations: ['0.0.0.0/0'] }
  ]
  vpc 'chef-provisioned-vpc'
  aws_tags chef_type: 'aws_security_group'
end

aws_route_table 'chef-provisioned-public' do
  vpc 'chef-provisioned-vpc'
  routes '0.0.0.0/0' => :internet_gateway
  aws_tags chef_type: 'aws_route_table'
end

aws_subnet 'chef-provisioned-subnet-2b' do
  vpc 'chef-provisioned-vpc'
  cidr_block '172.16.0.0/24'
  availability_zone 'us-west-2b'
  map_public_ip_on_launch true
  route_table 'chef-provisioned-main-route-table'
  aws_tags chef_type: 'aws_subnet'
  network_acl 'chef-provisioned-acl'
end

aws_subnet 'chef-provisioned-subnet-2c' do
  vpc 'chef-provisioned-vpc'
  cidr_block '172.17.0.0/24'
  availability_zone 'us-west-2c'
  map_public_ip_on_launch true
  route_table 'chef-provisioned-main-route-table'
  aws_tags chef_type: 'aws_subnet'
  network_acl 'chef-provisioned-acl'
end
