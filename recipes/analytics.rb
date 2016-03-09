# encoding: UTF-8

ingredient_config 'analytics' do
  config <<-EOF
topology 'standalone'
analytics_fqdn '#{node['server-provisioning']['analytics']['fqdn']}'
features['integration'] = #{node['server-provisioning']['analytics']['features']}
EOF
  action :add
end

chef_ingredient 'analytics' do
  action [:install, :reconfigure]
end
