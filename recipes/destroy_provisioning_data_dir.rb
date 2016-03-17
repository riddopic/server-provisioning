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
