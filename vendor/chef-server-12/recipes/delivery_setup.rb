# encoding: UTF-8

execute "Create #{node['chef-server-12']['delivery']['user']} User" do
  command "chef-server-ctl user-create #{node['chef-server-12']['delivery']['user']} \
            #{node['chef-server-12']['delivery']['name']} \
            #{node['chef-server-12']['delivery']['last_name']} \
            #{node['chef-server-12']['delivery']['email']} \
            #{node['chef-server-12']['delivery']['password']} \
            > #{node['chef-server-12']['delivery']['delivery_pem']}"
  sensitive true
  not_if "chef-server-ctl user-list | grep -w #{node['chef-server-12']['delivery']['user']}"
  not_if { ::File.exist?(node['chef-server-12']['delivery']['delivery_pem']) }
  notifies :run, "ruby_block[upload delivery key]" if node['chef-server-12']['store_keys_databag']
end

execute "Create #{node['chef-server-12']['delivery']['organization']} Organization" do
  command "chef-server-ctl org-create #{node['chef-server-12']['delivery']['organization']} \
            #{node['chef-server-12']['delivery']['org_longname']} -a #{node['chef-server-12']['delivery']['user']} \
            > #{node['chef-server-12']['delivery']['validator_pem']}"
  not_if "chef-server-ctl org-list | grep -w #{node['chef-server-12']['delivery']['organization']}"
end

execute "Associate Delivery User to #{node['chef-server-12']['delivery']['organization']} Organization" do
  command "chef-server-ctl org-user-add #{node['chef-server-12']['delivery']['organization']} \
            #{node['chef-server-12']['delivery']['user']} -a"
end

ruby_block "upload delivery key" do
  block do
    Chef::Config.new
    Chef::Config.chef_server_url = (node['chef-server-12']['delivery']['ssl'] ? "https" : "http") + "://#{node['chef-server-12']['api_fqdn']}/organizations/#{node['chef-server-12']['delivery']['organization']}"
    Chef::Config.client_key = node['chef-server-12']['delivery']['delivery_pem']
    Chef::Config.node_name = node['chef-server-12']['delivery']['user']

    begin
      bag = Chef::DataBag.new
      bag.name(node['chef-server-12']['delivery']['db'])
      bag.create
    rescue Exception => e
      puts "DataBag #{node['chef-server-12']['delivery']['db']} already exists."
    end

    begin
      data = Chef::EncryptedDataBagItem.encrypt_data_bag_item(
        { "content" => File.read(node['chef-server-12']['delivery']['delivery_pem']) },
        Chef::Config.encrypted_data_bag_secret)
      delivery_item = Chef::DataBagItem.from_hash({ "id" => node['chef-server-12']['delivery']['item'] }.merge(data))
      delivery_item.data_bag(node['chef-server-12']['delivery']['db'])
      delivery_item.save
    rescue Exception => e
      puts "Something went wrong with the data bag creation.\nERROR: #{e.message}"
    end
  end
  action :nothing
end
