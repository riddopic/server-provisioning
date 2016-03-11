# encoding: UTF-8

module Server
  module Helpers
    #
    # Supermarket Module
    #
    # This module provides helpers related to the Supermarket Component
    module Supermarket
      module_function

      # Get the Hostname of the Supermarket Server
      #
      # @param node [Chef::Node] Chef Node object
      # @return hostname [String] The hostname of the supermarket server
      def supermarket_server_hostname(node)
        Server::Helpers::Component.component_hostname(node, 'supermarket')
      end

      # Returns the FQDN of the Supermarket Server
      #
      # @param node [Chef::Node] Chef Node object
      # @return [String] Supermarket FQDN
      def supermarket_server_fqdn(node)
        @supermarket_server_fqdn ||=
          Server::Helpers::Component.component_fqdn(node, 'supermarket')
      end

      # Generates the Supermarket Server Attributes
      #
      # @param node [Chef::Node] Chef Node object
      # @return [Hash] Supermarket attributes for a machine resource
      def supermarket_server_attributes(node)
        return {} unless supermarket_enabled?(node)

        Chef::Mixin::DeepMerge.hash_only_merge(
          Server::Helpers::Component.component_attributes(node, 'supermarket'),
          'chef-server-12' => {
            'supermarket' => {
              'fqdn' => supermarket_server_fqdn(node)
            }
          }
        )
      end

      # Generates the Supermarket Server Config
      #
      # @param node [Chef::Node] Chef Node object
      # @return [Hash] Supermarket attributes for a machine resource
      def supermarket_config(node)
        return {} unless supermarket_enabled?(node)
        {
          'supermarket-config' => {
            'fqdn' => supermarket_server_fqdn(node),
            'host' => supermarket_server_fqdn(node),
            'chef_server_url' => "https://#{Server::Helpers::ChefServer.chef_server_fqdn(node)}",
            'chef_oauth2_app_id' => get_supermarket_attribute(node, 'uid'),
            'chef_oauth2_secret' => get_supermarket_attribute(node, 'secret'),
            'chef_oauth2_verify_ssl' => false
          }
        }
      end

      # Return an specific Supermarket Attribute
      # Parse the supermarket.json file and retrieve an specific attribute
      #
      # @param node [Chef::Node] Chef Node object
      # @param attr [String] Attribute to retrieve
      # @return [String] Supermarket attribute value
      def get_supermarket_attribute(node, attr)
        @supermarket ||= begin
          supermarket_file = File.read("#{Server::Helpers.provisioning_data_dir(node)}/supermarket.json")
          JSON.parse(supermarket_file)
        end
        @supermarket[attr]
      end

      # Activate the Supermarket Component
      # This method will touch a lock file to activate the supermarket component
      #
      # @param node [Chef::Node] Chef Node object
      def activate_supermarket(node)
        FileUtils.touch(supermarket_lock_file(node))
      end

      # Supermarket Lock File
      #
      # @param node [Chef::Node] Chef Node object
      # @return [String] The PATH of the supermarket lock file
      def supermarket_lock_file(node)
        "#{Server::Helpers.provisioning_data_dir(node)}/supermarket"
      end

      # Verify the state of the Supermarket Component
      # If the lock file exist, then we have the supermarket component enabled,
      # otherwise it is NOT enabled yet.
      #
      # @param node [Chef::Node] Chef Node object
      # @return [Bool] The state of the supermarket component
      def supermarket_enabled?(node)
        File.exist?(supermarket_lock_file(node))
      end
    end
  end

  # Module that exposes multiple helpers
  module DSL
    # Hostname of the Supermarket Server
    def supermarket_server_hostname
      Server::Helpers::Supermarket.supermarket_server_hostname(node)
    end

    # FQDN of the Supermarket Server
    def supermarket_server_fqdn
      Server::Helpers::Supermarket.supermarket_server_fqdn(node)
    end

    # Supermarket Server Attributes
    def supermarket_server_attributes
      Server::Helpers::Supermarket.supermarket_server_attributes(node)
    end

    # Generates the Supermarket Server Config
    def supermarket_config
      Server::Helpers::Supermarket.supermarket_config(node)
    end

    # Activate the Supermarket Component
    def activate_supermarket
      Server::Helpers::Supermarket.activate_supermarket(node)
    end

    # Supermarket Lock File
    def supermarket_lock_file
      Server::Helpers::Supermarket.supermarket_lock_file(node)
    end

    # Verify the state of the Supermarket Component
    def supermarket_enabled?
      Server::Helpers::Supermarket.supermarket_enabled?(node)
    end
  end
end