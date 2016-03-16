# encoding: UTF-8

# Analytics Server
include_recipe 'provisioning::destroy_analytics'

# Supermarket Server
include_recipe 'provisioning::destroy_supermarket'

# Chef Server
include_recipe 'provisioning::destroy_chef_server'

# Provisioning Data directory
include_recipe 'provisioning::destroy_provisioning_data_dir'

# AWS VPC, Subnet, ACLs and Security Groups
if provisioning.driver == 'aws'
  include_recipe 'provisioning::destroy_aws'
end
