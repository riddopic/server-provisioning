# encoding: UTF-8

ingredient_config 'analytics' do
  config <<-EOF
topology 'standalone'
analytics_fqdn '#{node['provisioning']['analytics']['fqdn']}'
features['integration'] = #{node['provisioning']['analytics']['features']}
EOF
  action :add
end

chef_ingredient 'analytics' do
  action [:install, :reconfigure]
end
