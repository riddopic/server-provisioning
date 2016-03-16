# encoding: UTF-8

# Abstract the specific configurations by providers
include_recipe 'provisioning::_settings'

# Setup the AWS security groups
include_recipe 'provisioning::setup_security_group'

# Bootstrap a Chef Server instance with Chef-Zero
include_recipe 'provisioning::setup_chef_server'

# Create a Supermarket Server if enabled
unless node['provisioning']['supermarket'].nil?
  include_recipe 'provisioning::setup_supermarket'
end
