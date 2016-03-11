# encoding: UTF-8

require 'openssl'
require 'fileutils'
require 'securerandom'

module Server
  #
  # Helpers Module for general purposes
  #
  module Helpers
    module_function

    # Retrive the common provisioning recipes.
    #
    def common_provisioning_recipes(node)
      default_provisioning_recipes + node['server-provisioning']['common_provisioning_recipes']
    end

    # Retrive the default provisioning recipes.
    #
    def default_provisioning_recipes
      ['server-provisioning::pkg_repo_management']
    end

    # Provisioning Driver Instance
    #
    # @param node [Chef::Node] Chef Node object
    # @return [Server::Provisioning::Base] provisioning driver instance
    def provisioning(node)
      check_attribute?(node['server-provisioning']['driver'], "node['server-provisioning']['driver']")
      @provisioning ||= Server::Provisioning.driver(node['server-provisioning']['driver'], node)
    end

    # The current directory PATH from `.chef/knife.rb`
    #
    # @return [String] current directory path
    def current_dir
      Chef::Config.chef_repo_path
    end

    # Chef Provisioning directory link
    #
    # @return [Bool] True if cluster directory is a link, False if not
    def provisioning_data_dir_link?
      File.symlink?(File.join(current_dir, '.chef', 'provisioning-data'))
    end

    # Chef Provisioning data directory
    #
    # @param node [Chef::Node] Chef Node object
    # @return [String] PATH of the Delivery cluster data directory
    def provisioning_data_dir(node)
      File.join(current_dir, '.chef', "provisioning-data-#{chef_provisioning_id(node)}")
    end

    # Use the Private IP for SSH
    #
    # @param node [Chef::Node] Chef Node object
    # @return [Bool] True if we need to use the private ip for ssh, False if not
    def use_private_ip_for_ssh(node)
      check_attribute?(node['server-provisioning']['driver'], "node['server-provisioning']['driver']")
      node['server-provisioning'][node['server-provisioning']['driver']]['use_private_ip_for_ssh']
    end

    # Get the IP address from the Provisioning Abstraction
    #
    # @param node [Chef::Node] Chef Node object
    # @param machine_node [Chef::Node][Hash] Chef Node or Hash object of the
    #   machine we would like to get the ipaddress from
    # @return [String] ip address
    def get_ip(node, machine_node)
      machine_node = Chef::Node.json_create(machine_node) if machine_node.class.eql?(Hash)
      provisioning(node).ipaddress(machine_node)
    end

    # Extracting the username from the provisioning abstraction
    #
    # @param node [Chef::Node] Chef Node object
    # @return [String] username
    def username(node)
      provisioning(node).username
    end

    # Chef Provisioning ID
    # If a provisioning id was not provided (via the attribute) we'll generate
    # a unique cluster id and immediately save it in case the CCR fails.
    #
    # @param node [Chef::Node] Chef Node object
    # @return [String] provisioning id
    def chef_provisioning_id(node)
      unless node['server-provisioning']['id']
        node.set['server-provisioning']['id'] = "test-#{SecureRandom.hex(3)}"
        node.save
      end

      node['server-provisioning']['id']
    end

    # Encrypted Data Bag Secret
    # Generate or load an existing encrypted data bag secret
    #
    # @param node [Chef::Node] Chef Node object
    # @return [String] encrypted data bag secret
    def encrypted_data_bag_secret(node)
      @encrypted_data_bag_secret ||= begin
        if File.exist?("#{provisioning_data_dir(node)}/encrypted_data_bag_secret")
          File.read("#{provisioning_data_dir(node)}/encrypted_data_bag_secret")
        else
          SecureRandom.base64(512)
        end
      end
    end

    # Generate Knife Variables
    # To use them to create a new knife config file that will point at the newly
    # provisioned Chef server to facilitate its management within the
    # `provisioning_data_dir`
    #
    # @param node [Chef::Node] Chef Node object
    # @return [Hash] knife variables to render a customized knife.rb
    def knife_variables(node)
      {
        chef_server_url:      Server::Helpers::ChefServer.chef_server_url(node),
        client_key:           "#{provisioning_data_dir(node)}/provisioner.pem",
        analytics_server_url: if Server::Helpers::Analytics.analytics_enabled?(node)
                                "https://#{Server::Helpers::Analytics.analytics_server_fqdn(node)}/organizations" \
                                "/#{node['server-provisioning']['chef-server']['organization']}"
                              else
                                ''
                              end,
        supermarket_site:     if Server::Helpers::Supermarket.supermarket_enabled?(node)
                                "https://#{Server::Helpers::Supermarket.supermarket_server_fqdn(node)}"
                              else
                                ''
                              end
      }
    end

    # Validate Attribute
    # As we depend on many attributes for multiple components we need a
    # quick way to validate when they have been set or not.
    #
    # @param attr_value [NotNilValue] value of the attribute we want to check
    # @param attr_name [String] name of the attribute
    def check_attribute?(attr_value, attr_name)
      raise Chef::Exceptions::AttributeNotFound, attr_name if attr_value.nil?
    end
  end

  # Module that exposes multiple helpers
  module DSL
    # Retrive the common cluster recipes
    def common_provisioning_recipes
      Server::Helpers.common_provisioning_recipes(node)
    end

    # Provisioning Driver Instance
    def provisioning
      Server::Helpers.provisioning(node)
    end

    # The current directory PATH
    def current_dir
      Server::Helpers.current_dir
    end

    # Cluster Data directory link
    def provisioning_data_dir_link?
      Server::Helpers.provisioning_data_dir_link?
    end

    # Chef Provisioning data directory
    def provisioning_data_dir
      Server::Helpers.provisioning_data_dir(node)
    end

    # Use the Private IP for SSH
    def use_private_ip_for_ssh
      Server::Helpers.use_private_ip_for_ssh(node)
    end

    # Get the IP address from the Provisioning Abstraction
    def get_ip(machine_node)
      Server::Helpers.get_ip(node, machine_node)
    end

    # Extracting the username from the provisioning abstraction
    def username
      Server::Helpers.username(node)
    end

    # Chef Provisioning ID
    def chef_provisioning_id
      Server::Helpers.chef_provisioning_id(node)
    end

    # Encrypted Data Bag Secret
    def encrypted_data_bag_secret
      Server::Helpers.encrypted_data_bag_secret(node)
    end

    # Generate Knife Variables
    def knife_variables
      Server::Helpers.knife_variables(node)
    end
  end
end
