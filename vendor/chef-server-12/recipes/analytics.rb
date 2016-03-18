# encoding: UTF-8

if File.exist?('/etc/opscode/chef-server.rb')
  template '/etc/opscode/chef-server.rb' do
    owner 'root'
    mode 00644
    not_if 'grep analytics /etc/opscode/chef-server.rb'
    # notifies :run, 'execute[stop chef]', :immediately
    notifies :run, 'execute[reconfigure chef]', :immediately
    notifies :run, 'execute[restart chef]', :immediately
    notifies :run, 'execute[reconfigure opscode-manage]', :immediately
  end if node['chef-server-12']['analytics']

  %w(restart stop reconfigure).each do |cmd|
    execute "#{cmd} chef" do
      command "chef-server-ctl #{cmd}"
      action :nothing
    end
  end

  execute 'reconfigure opscode-manage' do
    command 'opscode-manage-ctl reconfigure'
    action :nothing
  end
end
