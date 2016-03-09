# encoding: UTF-8

# Abstract the specific configurations by providers
include_recipe 'server-provisioning::_settings'

# Bootstrap a Chef Server instance with Chef-Zero
include_recipe 'server-provisioning::setup_chef_server'

# Create a Supermarket Server if enabled
unless node['server-provisioning']['supermarket'].nil?
  include_recipe 'server-provisioning::setup_supermarket'
end
