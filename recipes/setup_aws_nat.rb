# encoding: UTF-8

include_recipe 'aws'
include_recipe 'sysctl'

sysctl_param 'net.ipv4.ip_forward' do
  value 1
end

include_recipe 'iptables'

iptables_rule '10-masquerade' do
  source 'masquerade.erb'
  variables(cidr: node[:nat][:cidr])
end

Chef::Recipe.send(:include, Kinesis::Aws)

ec2 = aws_resource('EC2', node['ec2']['placement_availability_zone'].chop)
instance = ec2.instance(node['ec2']['instance_id'])

# Disable source/dest check to false.
instance.modify_attribute(source_dest_check: { value: false })

if instance.vpc_id.nil?
  raise "Could not determine instance #{node['ec2']['instance_id']}'s VPC ID. "\
        'Are you running in a VPC?'
end

# Find all subnets that are tagged network=private
subnets = ec2.subnets(filters: [
  {
    name: 'availability-zone',
    values: [node['ec2']['placement_availability_zone']]
  },
  {
    name: 'vpc-id',
    values: [instance.vpc_id]
  },
  {
    name: 'state',
    values: ['available']
  },
  {
    name: 'tag:network',
    values: ['private']
  }
]).to_a

if subnets.empty?
  raise "Could not find private subnets for VPC #{instance.vpc_id}"
end

# Find all route tables associated with private subnets
route_tables = ec2.route_tables(filters: [
  {
    name: 'vpc-id',
    values: [instance.vpc_id]
  },
  {
    name: 'tag:network',
    values: ['private']
  },
  {
    name: 'association.subnet-id',
    values: subnets.map(&:id)
  }
]).to_a

if route_tables.empty?
  raise "Could not find any route tables for subnet #{instance.subnet.id}"
end

# Replace the default route with route to this instance
ec2_old_client = aws_client('EC2', node['ec2']['placement_availability_zone'].chop)
route_tables.each do |route_table|
  options = {
    route_table_id: route_table.route_table_id,
    destination_cidr_block: '0.0.0.0/0',
    instance_id: node['ec2']['instance_id']
  }

  if route_table.routes.any? { |r| r.destination_cidr_block == '0.0.0.0/0' }
    ec2_old_client.replace_route(options)
  else
    ec2_old_client.create_route(options)
  end
end
