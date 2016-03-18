# encoding: UTF-8

if platform? 'debian'
  include_recipe 'apt'

elsif platform? 'rhel'
  include_recipe 'yum'

else
  Chef::Log.warn "Unknown or unsupported platform '#{platform?}' detected."
  return
end

include_recipe 'openssh'
include_recipe 'ntp'
