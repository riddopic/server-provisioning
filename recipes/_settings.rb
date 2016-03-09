# encoding: UTF-8

with_driver provisioning.driver

with_machine_options(provisioning.machine_options)

# Link the actual "provisioning_data_dir" to "provisioning-data"
# so that ".chef/knife.rb" knows which one is our working cluster
link File.join(current_dir, '.chef', 'provisioning-data') do
  to provisioning_data_dir
end
