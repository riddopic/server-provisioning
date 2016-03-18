# encoding: UTF-8

if File.exist?('/etc/opscode/chef-server.rb')
  template '/etc/opscode/chef-server.rb' do
    owner 'root'
    mode 00644
    not_if 'grep supermarket /etc/opscode/chef-server.rb'
    notifies :run, 'execute[reconfigure chef]', :immediately
  end if node['chef-server-12']['supermarket']

  execute 'reconfigure chef' do
    command 'chef-server-ctl reconfigure'
    action :nothing
  end
end
