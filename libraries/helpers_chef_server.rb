# encoding: UTF-8

require 'securerandom'

module Server
  module Helpers
    #
    # ChefServer Module
    #
    # This module provides helpers related to the Chef Server Component
    module ChefServer
      module_function

      # Password of the Provisioning User
      # Generate or load the password of the provisioning user in chef-server
      #
      # @param node [Chef::Node] Chef Node object
      # @return [String] password of the provisioning user
      def provisioning_password(node)
        @provisioning_password ||= begin
          if File.exist?("#{Server::Helpers.provisioning_data_dir(node)}/provisioning_password")
            File.read("#{Server::Helpers.provisioning_data_dir(node)}/provisioning_password")
          elsif node['server-provisioning']['chef-server']['provisioning_password']
            node['server-provisioning']['chef-server']['provisioning_password']
          else
            SecureRandom.base64(20)
          end
        end
      end

      # Upload a specific cookbook to our chef-server
      #
      # @param node [Chef::Node] Chef Node object
      # @param cookbook [String] Cookbook Name
      def upload_cookbook(node, cookbook)
        execute "Upload Cookbook => #{cookbook}" do
          command "knife cookbook upload #{cookbook} --cookbook-path #{Chef::Config[:cookbook_path]}"
          environment(
            'KNIFE_HOME' => Server::Helpers.provisioning_data_dir(node)
          )
          not_if "knife cookbook show #{cookbook}"
        end
      end

      # Get the Hostname of the Chef Server
      #
      # @param node [Chef::Node] Chef Node object
      # @return hostname [String] The hostname of the chef-server
      def chef_server_hostname(node)
        Server::Helpers::Component.component_hostname(node, 'chef-server')
      end

      # Returns the FQDN of the Chef Server
      #
      # @param node [Chef::Node] Chef Node object
      # @return [String]
      def chef_server_fqdn(node)
        @chef_server_fqdn ||= begin
          chef_server_node = Chef::Node.load(chef_server_hostname(node))
          Server::Helpers::Component.component_fqdn(node, 'chef-server', chef_server_node)
        end
      end

      # Returns the Chef Server URL of our Organization
      #
      # @param node [Chef::Node] Chef Node object
      # @return [String] chef-server url
      def chef_server_url(node)
        "https://#{chef_server_fqdn(node)}/organizations/#{node['server-provisioning']['chef-server']['organization']}"
      end

      # Generates the Chef Server Attributes
      #
      # @param node [Chef::Node] Chef Node object
      # @return [Hash] chef-server attributes
      def chef_server_attributes(node)
        @chef_server_attributes = {
          'chef-server-12' => {
            'provisioner' => {
              'organization' => node['server-provisioning']['chef-server']['organization'],
              'password' => provisioning_password(node)
            },
            'api_fqdn' => chef_server_fqdn(node),
            'store_keys_databag' => false,
            'plugin' => {
              'reporting' => node['server-provisioning']['chef-server']['enable-reporting']
            }
          }
        }
        @chef_server_attributes = Chef::Mixin::DeepMerge.hash_only_merge(
          @chef_server_attributes,
          Server::Helpers::Analytics.analytics_server_attributes(node)
        )
        @chef_server_attributes = Chef::Mixin::DeepMerge.hash_only_merge(
          @chef_server_attributes,
          Server::Helpers::Supermarket.supermarket_server_attributes(node)
        )
        @chef_server_attributes = Chef::Mixin::DeepMerge.hash_only_merge(
          @chef_server_attributes,
          Server::Helpers::Component.component_attributes(node, 'chef-server')
        )
        @chef_server_attributes
      end

      # Chef Server Config
      # This is used by all the `machine` resources to point to our chef-server
      # and any interaction we have with the chef-server like data-bags, roles, etc.
      #
      # @param node [Chef::Node] Chef Node object
      # @return [Hash] chef-server attributes
      def chef_server_config(node)
        {
          chef_server_url: chef_server_url(node),
          options: {
            client_name: 'provisioner',
            signing_key_filename: "#{Server::Helpers.provisioning_data_dir(node)}/provisioner.pem"
          }
        }
      end
    end
  end

  # Module that exposes multiple helpers
  module DSL
    # Password of the Provisioning User
    def provisioning_password
      Server::Helpers::ChefServer.provisioning_password(node)
    end

    # Upload a cookbook to the chef-server
    def upload_cookbook(cookbook)
      Server::Helpers::ChefServer.upload_cookbook(node, cookbook)
    end

    # Get the Hostname of the Chef Server
    def chef_server_hostname
      Server::Helpers::ChefServer.chef_server_hostname(node)
    end

    # Return the chef-server config
    def chef_server_config
      Server::Helpers::ChefServer.chef_server_config(node)
    end

    # Return the FQDN of the Chef Server
    def chef_server_fqdn
      Server::Helpers::ChefServer.chef_server_fqdn(node)
    end

    # Return the Chef Server URL of our Organization
    def chef_server_url
      Server::Helpers::ChefServer.chef_server_url(node)
    end

    # Generate the Chef Server Attributes
    def chef_server_attributes
      Server::Helpers::ChefServer.chef_server_attributes(node)
    end
  end
end
