# encoding: UTF-8

include_recipe 'server-provisioning::_settings'

aws_vpc 'chef-vpc' do
  cidr_block '10.0.0.0/24'
  internet_gateway true
  main_routes '0.0.0.0/0' => :internet_gateway
end

aws_subnet 'subnet-a' do
  vpc 'chef-vpc'
  cidr_block '10.0.0.0/26'
  availability_zone 'us-west-2a'
  map_public_ip_on_launch true
end

aws_subnet 'subnet-b' do
  vpc 'chef-vpc'
  cidr_block '10.0.0.128/26'
  availability_zone 'us-west-2b'
  map_public_ip_on_launch true
end

aws_security_group 'chef-sg' do
  inbound_rules [
    { # SSH
      port: 22,
      protocol: :tcp,
      sources: node['server-provisioning']['inbound_rules']['source-ip']
    },
    { # HTTP
      port: 80,
      protocol: :tcp,
      sources: node['server-provisioning']['inbound_rules']['source-ip']
    },
    { # HTTPS
      port: 443,
      protocol: :tcp,
      sources: node['server-provisioning']['inbound_rules']['source-ip']
    },
    { # Git (SCM)
      port: 8989,
      protocol: :tcp,
      sources: node['server-provisioning']['inbound_rules']['source-ip']
    },
    { # Analytics MQ
      port: 5672,
      protocol: :tcp,
      sources: node['server-provisioning']['inbound_rules']['source-ip']
    },
    { # Push Jobs
      port: 10000..10003,
      protocol: :tcp,
      sources: node['server-provisioning']['inbound_rules']['source-ip']
    },
    { # Analytics Messages/Notifier
      port: 10012..10013,
      protocol: :tcp,
      sources: node['server-provisioning']['inbound_rules']['source-ip']
    }
  ]
  outbound_rules [
    { port: 0..65535, destinations: ['0.0.0.0/0'] }
  ]
  vpc 'chef-vpc'
  aws_tags chef_type: 'aws_security_group'
end
