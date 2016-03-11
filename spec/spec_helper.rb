# encoding: UTF-8

require 'chefspec'
require 'chefspec/berkshelf'
require 'chef/node'
require 'chef/server_api'

TOPDIR = File.expand_path(File.join(File.dirname(__FILE__), '..'))
$LOAD_PATH << File.expand_path(File.dirname(__FILE__))

# Include all our libraries
Dir['libraries/*.rb'].each { |f| require File.expand_path(f) }

# Provisioning Drivers Data
module SharedDriverData
  extend RSpec::SharedContext

  let(:ssh_data) do
    {
      'ssh_username' => 'ubuntu',
      'prefix' => 'gksudo ',
      'key_file' => '/Users/sharding/.vagrant.d/insecure_private_key',
      'bootstrap_proxy' => 'http://my-proxy.com/',
      'chef_config' => "http_proxy 'http://my-proxy.com/'\nno_proxy 'localhost'",
      'chef_version' => '12.3.0'
    }
  end

  let(:vagrant_data) do
    {
      'vm_box' => 'opscode-ubuntu-14.04',
      'image_url' => 'https://opscode-bento.com/opscode_ubuntu-14.04.box',
      'vm_memory' => '2048',
      'vm_cpus' => '2',
      'key_file' => '/Users/sharding/.vagrant.d/insecure_private_key',
      'use_private_ip_for_ssh' => false,
      'bootstrap_proxy' => 'http://my-proxy.com/',
      'chef_config' => "http_proxy 'http://my-proxy.com/'\nno_proxy 'localhost'",
      'chef_version' => '12.0.0',
      'install_sh_path' => '/custom/path/awesome_install.sh'
    }
  end

  let(:aws_data) do
    {
      'flavor' => 'c3.xlarge',
      'image_id' => 'ami-a52bc9c5',
      'key_name' => 'sharding',
      'subnet_id' => 'sg-7751da10',
      'ssh_username' => 'ubuntu',
      'security_group_ids' => 'sg-7751da10',
      'use_private_ip_for_ssh' => true,
      'bootstrap_proxy' => 'http://my-proxy.com/',
      'chef_config' => "http_proxy 'http://my-proxy.com/'\nno_proxy 'localhost'",
      'install_sh_path' => '/wrong_place.sh'
    }
  end
end

# Common shared data
module SharedCommonData
  extend RSpec::SharedContext

  let(:cluster_data) do
    {
      'id' => 'chefspec',
      'trusted_certs' => {},
      'chef-server' => {
        'organization' => 'chefspec',
        'fqdn' => 'chef-server.chef.io',
        'host' => 'chef-server.chef.io',
        'existing' => false,
        'aws_tags' => {
          'cool_tag' => 'awesomeness',
          'important' => 'thing'
        }
      },
      'analytics' => {
        'fqdn' => 'analytics-server.chef.io',
        'host' => 'analytics-server.chef.io'
      },
      'supermarket' => {
        'fqdn' => 'supermarket-server.chef.io',
        'host' => 'supermarket-server.chef.io'
      }
    }
  end
  let(:rest) do
    Chef::ServerAPI.new(
      'https://chef-server.chef.io/organizations/chefspec',
      client_name: 'provisioner',
      signing_key_filename: File.expand_path('spec/unit/mock/provisioner.pem')
    )
  end
  let(:chef_node) do
    {
      'normal' => {
        'server-provisioning' => {
          'driver' => 'ssh',
          'ssh' => {}
        },
        'ipaddress' => '10.1.1.1'
      },
      'recipes' => []
    }
  end
  let(:supermarket_node) do
    {
      'normal' => {
        'server-provisioning' => {
          'driver' => 'aws',
          'aws' => {}
        },
        'ec2' => {
          'local_ipv4' => '10.1.1.3'
        },
        'ipaddress' => '10.1.1.3'
      },
      'recipes' => []
    }
  end
  let(:analytics_node) do
    {
      'normal' => {
        'server-provisioning' => {
          'driver' => 'ssh',
          'ssh' => {}
        },
        'ipaddress' => '10.1.1.4'
      },
      'recipes' => []
    }
  end
end

RSpec.configure do |config|
  config.include SharedDriverData
  config.include SharedCommonData
  config.filter_run_excluding ignore: true
  config.platform = 'ubuntu'
  config.version = '14.04'
end
