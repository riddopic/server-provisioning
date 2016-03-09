# encoding: UTF-8

case node['platform_family']
when 'debian'
  # Force the update at compile time
  node.set['apt']['compile_time_update'] = true
  include_recipe 'apt'
when 'rhel'
  include_recipe 'yum'
  # By default yum should clean the cache but we are going to force it
  # to ensure we will get the latest packages from our repositories.
  execute 'yum clean all' do
    action :nothing
  end.run_action(:run)
end
