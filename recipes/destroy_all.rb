# encoding: UTF-8

# Chef Analytics Server
include_recipe 'provisioning::destroy_analytics'

# Chef Compliance Server
include_recipe 'provisioning::destroy_compliance'

# Chef Supermarket Server
include_recipe 'provisioning::destroy_supermarket'

# Splunk Server
include_recipe 'provisioning::destroy_splunk'

# Splunk Server
include_recipe 'provisioning::destroy_jenkins_server'

# Splunk Server
include_recipe 'provisioning::destroy_jenkins_worker'

# Chef Server
include_recipe 'provisioning::destroy_chef_server'

# Provisioning Data directory
include_recipe 'provisioning::destroy_provisioning_data_dir'
