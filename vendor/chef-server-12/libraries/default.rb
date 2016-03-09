# encoding: UTF-8

def install_plugin(plugin)
  chef_ingredient plugin do
    action :install
    notifies :reconfigure, "chef_ingredient[chef-server]", :immediately
  end

  ingredient_config plugin do
    notifies :reconfigure, "chef_ingredient[#{plugin}]", :immediately
  end
end
