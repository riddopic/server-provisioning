# encoding: UTF-8

execute "Create #{node['chef-server-12']['provisioner']['user']} User" do
  command "chef-server-ctl user-create #{node['chef-server-12']['provisioner']['user']} \
            #{node['chef-server-12']['provisioner']['name']} \
            #{node['chef-server-12']['provisioner']['last_name']} \
            #{node['chef-server-12']['provisioner']['email']} \
            #{node['chef-server-12']['provisioner']['password']} \
            > #{node['chef-server-12']['provisioner']['provisioner_pem']}"
  sensitive true
  not_if "chef-server-ctl user-list | grep -w #{node['chef-server-12']['provisioner']['user']}"
  not_if { ::File.exist?(node['chef-server-12']['provisioner']['provisioner_pem']) }
  notifies :run, "ruby_block[upload provisioner key]" if node['chef-server-12']['store_keys_databag']
end

execute "Create #{node['chef-server-12']['provisioner']['organization']} Organization" do
  command "chef-server-ctl org-create #{node['chef-server-12']['provisioner']['organization']} \
            #{node['chef-server-12']['provisioner']['org_longname']} -a #{node['chef-server-12']['provisioner']['user']} \
            > #{node['chef-server-12']['provisioner']['validator_pem']}"
  not_if "chef-server-ctl org-list | grep -w #{node['chef-server-12']['provisioner']['organization']}"
end

execute "Associate Provisioner User to #{node['chef-server-12']['provisioner']['organization']} Organization" do
  command "chef-server-ctl org-user-add #{node['chef-server-12']['provisioner']['organization']} \
            #{node['chef-server-12']['provisioner']['user']} -a"
end

ruby_block "upload provisioner key" do
  block do
    Chef::Config.new
    Chef::Config.chef_server_url = (node['chef-server-12']['provisioner']['ssl'] ? "https" : "http") + "://#{node['chef-server-12']['api_fqdn']}/organizations/#{node['chef-server-12']['provisioner']['organization']}"
    Chef::Config.client_key = node['chef-server-12']['provisioner']['provisioner_pem']
    Chef::Config.node_name = node['chef-server-12']['provisioner']['user']

    begin
      bag = Chef::DataBag.new
      bag.name(node['chef-server-12']['provisioner']['db'])
      bag.create
    rescue Exception => e
      puts "DataBag #{node['chef-server-12']['provisioner']['db']} already exists."
    end

    begin
      data = Chef::EncryptedDataBagItem.encrypt_data_bag_item(
        { "content" => File.read(node['chef-server-12']['provisioner']['provisioner_pem']) },
        Chef::Config.encrypted_data_bag_secret)
      provisioner_item = Chef::DataBagItem.from_hash({ "id" => node['chef-server-12']['provisioner']['item'] }.merge(data))
      provisioner_item.data_bag(node['chef-server-12']['provisioner']['db'])
      provisioner_item.save
    rescue Exception => e
      puts "Something went wrong with the data bag creation.\nERROR: #{e.message}"
    end
  end
  action :nothing
end
