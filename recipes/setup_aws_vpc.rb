# encoding: UTF-8

include_recipe 'provisioning::_settings'

aws_dhcp_options 'dhcp-options' do
  domain_name 'aws.amazon.com'
  domain_name_servers ['8.8.8.8', '8.8.4.4']
  ntp_servers ['8.8.8.8', '8.8.4.4']
  netbios_name_servers ['8.8.8.8', '8.8.4.4']
  netbios_node_type 2
  aws_tags generate_tags('dhcp-options')
end

aws_vpc 'provisioned-aws-vpc' do
  cidr_block '172.16.0.0/16'
  internet_gateway true
  instance_tenancy :default
  dhcp_options 'dhcp-options'
  enable_dns_support true
  enable_dns_hostnames true
  aws_tags generate_tags('provisioned-aws-vpc')
end

aws_security_group 'nat' do
  inbound_rules [
    { port: 22,  protocol: :tcp,  sources: ['172.16.2.0/24'] },
    { port: 80,  protocol: :tcp,  sources: ['172.16.2.0/24'] },
    { port: 443, protocol: :tcp,  sources: ['172.16.2.0/24'] },
    {            protocol: :icmp, sources: ['0.0.0.0/0'] }
  ]
  outbound_rules [
    { port: 22,  protocol: :tcp,  sources: ['0.0.0.0/0'] },
    { port: 80,  protocol: :tcp,  sources: ['0.0.0.0/0'] },
    { port: 443, protocol: :tcp,  sources: ['0.0.0.0/0'] },
    {            protocol: :icmp, sources: ['0.0.0.0/0'] }
  ]
  vpc 'provisioned-aws-vpc'
  aws_tags generate_tags('aws_security_group')
end

aws_subnet 'public-subnet' do
  vpc 'provisioned-aws-vpc'
  cidr_block '172.16.1.0/24'
  availability_zone 'us-west-2b'
  # map_public_ip_on_launch true
  # route_table 'public-subnet-route-table'
  # network_acl 'public-subnet-acl'
  aws_tags generate_tags('public-subnet')
end

aws_route_table 'public-subnet-route-table' do
  vpc 'provisioned-aws-vpc'
  aws_tags generate_tags('public-subnet-route-table')
end

aws_vpc 'provisioned-aws-vpc' do
  main_route_table 'main-route-table'
end

aws_route_table 'private-subnet-route' do
  vpc 'provisioned-aws-vpc'
  routes '0.0.0.0/0' => :internet_gateway
  aws_tags generate_tags('private-subnet-route')
end

aws_network_acl 'private-subnet-acl' do
  inbound_rules [
    { rule_number: 100, action: :allow, protocol: 6, cidr_block: '24.7.32.100/32', port_range: 80..80 },
    { rule_number: 110, action: :allow, protocol: 6, cidr_block: '24.7.32.100/32', port_range: 443..443 },
    { rule_number: 120, action: :allow, protocol: 6, cidr_block: '24.7.32.100/32', port_range: 22..22 },
    { rule_number: 140, action: :allow, protocol: 6, cidr_block: '0.0.0.0/0',      port_range: 49152..65535 }
  ]
  outbound_rules [
    { rule_number: 100, action: :allow, protocol: 6, cidr_block: '0.0.0.0/0',     port_range: 80..80 },
    { rule_number: 110, action: :allow, protocol: 6, cidr_block: '0.0.0.0/0',     port_range: 443..443 },
    { rule_number: 140, action: :allow, protocol: 6, cidr_block: '0.0.0.0/0',     port_range: 49152..65535 },
    { rule_number: 150, action: :allow, protocol: 6, cidr_block: '172.16.1.0/24', port_range: 22..22 }
  ]
  vpc 'provisioned-aws-vpc'
  aws_tags generate_tags('private-subnet-acl')
end

aws_subnet 'public-subnet' do
  vpc 'provisioned-aws-vpc'
  cidr_block '172.16.1.0/24'
  availability_zone 'us-west-2b'
  map_public_ip_on_launch true
  route_table 'public-subnet-route'
  network_acl 'public-subnet-acl'
  aws_tags generate_tags('public-subnet')
end

aws_route_table 'private-route' do
  vpc 'provisioned-aws-vpc'
  aws_tags generate_tags('private-route')
end

aws_network_acl 'private-subnet-acl' do
  inbound_rules [
    { rule_number: 120, action: :allow, protocol: 6, cidr_block: '172.16.1.0/24', port_range: 22..22 },
    { rule_number: 140, action: :allow, protocol: 6, cidr_block: '0.0.0.0/0',     port_range: 49152..65535 }
  ]
  outbound_rules [
    { rule_number: 100, action: :allow, protocol: 6, cidr_block: '0.0.0.0/0',     port_range: 80..80 },
    { rule_number: 110, action: :allow, protocol: 6, cidr_block: '0.0.0.0/0',     port_range: 443..443 },
    { rule_number: 120, action: :allow, protocol: 6, cidr_block: '172.16.1.0/24', port_range: 49152..65535 }
  ]
  vpc 'provisioned-aws-vpc'
  aws_tags generate_tags('private-subnet-acl')
end

aws_subnet 'private-subnet' do
  vpc 'provisioned-aws-vpc'
  cidr_block '172.16.2.0/24'
  availability_zone 'us-west-2b'
  map_public_ip_on_launch false
  route_table 'private-subnet-route'
  network_acl 'private-subnet-acl'
  aws_tags generate_tags('private-subnet')
end

aws_key_pair 'key-pair' do
  private_key_options({
    format: :pem,
    type: :rsa,
    regenerate_if_different: true
  })
  allow_overwrite true
end
