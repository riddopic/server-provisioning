# encoding: UTF-8

with_driver provisioning.driver

with_machine_options(provisioning.machine_options)

# Link the actual "provisioning_data_dir" to "provisioning-data"
# so that ".chef/knife.rb" knows which one is our working cluster
link File.join(current_dir, '.chef', 'provisioning-data') do
  to provisioning_data_dir
end

# Configure AWS network resources (VPC, Subnet, ACLs and Security Groups).
if provisioning.driver == 'aws'
  include_recipe 'server-provisioning::_setup_aws'
end
