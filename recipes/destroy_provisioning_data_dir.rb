# encoding: UTF-8

# Delete Link `provisioning-data`
link File.join(current_dir, '.chef', 'provisioning-data') do
  action :delete
  only_if { provisioning_data_dir_link? }
end

# Delete `provisioning_data_dir` directory
directory provisioning_data_dir do
  ignore_failure true
  recursive true
  action :delete
end

# Destroy the EIP when using the AWS driver
aws_eip_address 'chef-server-p' do
  ignore_failure true
  action :disassociate
  only_if { provisioning.driver == 'aws' }
end
