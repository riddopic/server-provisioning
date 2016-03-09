# encoding: UTF-8

# Analytics Server
include_recipe 'server-provisioning::destroy_analytics'

# Supermarket Server
include_recipe 'server-provisioning::destroy_supermarket'

# Chef Server
include_recipe 'server-provisioning::destroy_chef_server'

# Provisioning Data directory
include_recipe 'server-provisioning::destroy_provisioning_data_dir'
