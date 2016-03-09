# encoding: UTF-8

module Server
  module Helpers
    #
    # Analytics Module
    #
    # This module provides helpers related to the Analytics Component
    module Analytics
      module_function

      # Get the Hostname of the Analytics Server
      #
      # @param node [Chef::Node] Chef Node object
      # @return hostname [String] The hostname of the Analytics server
      def analytics_server_hostname(node)
        Server::Helpers::Component.component_hostname(node, 'analytics')
      end

      # Returns the FQDN of the Analytics Server
      #
      # @param node [Chef::Node] Chef Node object
      # @return [String] Analytics FQDN
      def analytics_server_fqdn(node)
        @analytics_server_fqdn ||=
          Server::Helpers::Component.component_fqdn(node, 'analytics')
      end

      # Generates the Analytics Server Attributes
      #
      # @param node [Chef::Node] Chef Node object
      # @return [Hash] Analytics attributes for a machine resource
      def analytics_server_attributes(node)
        return {} unless analytics_enabled?(node)

        Chef::Mixin::DeepMerge.hash_only_merge(
          Server::Helpers::Component.component_attributes(node, 'analytics'),
          'chef-server-12' => {
            'analytics' => {
              'fqdn' => analytics_server_fqdn(node)
            }
          }
        )
      end

      # Activate the Analytics Component
      # This method will touch a lock file to activate the Analytics component
      #
      # @param node [Chef::Node] Chef Node object
      def activate_analytics(node)
        FileUtils.touch(analytics_lock_file(node))
      end

      # Analytics Lock File
      #
      # @param node [Chef::Node] Chef Node object
      # @return [String] The PATH of the Analytics lock file
      def analytics_lock_file(node)
        "#{Server::Helpers.provisioning_data_dir(node)}/analytics"
      end

      # Verify the state of the Analytics Component
      # If the lock file exist, then we have the Analytics component enabled,
      # otherwise it is NOT enabled yet.
      #
      # @param node [Chef::Node] Chef Node object
      # @return [Bool] The state of the Analytics component
      def analytics_enabled?(node)
        File.exist?(analytics_lock_file(node))
      end
    end
  end

  # Module that exposes multiple helpers
  module DSL
    # Hostname of the Analytics Server
    def analytics_server_hostname
      Server::Helpers::Analytics.analytics_server_hostname(node)
    end

    # FQDN of the Analytics Server
    def analytics_server_fqdn
      Server::Helpers::Analytics.analytics_server_fqdn(node)
    end

    # Analytics Server Attributes
    def analytics_server_attributes
      Server::Helpers::Analytics.analytics_server_attributes(node)
    end

    # Activate the Analytics Component
    def activate_analytics
      Server::Helpers::Analytics.activate_analytics(node)
    end

    # Analytics Lock File
    def analytics_lock_file
      Server::Helpers::Analytics.analytics_lock_file(node)
    end

    # Verify the state of the Analytics Component
    def analytics_enabled?
      Server::Helpers::Analytics.analytics_enabled?(node)
    end
  end
end
