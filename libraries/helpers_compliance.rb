# encoding: UTF-8

module Server
  module Helpers
    #
    # Compliance Module
    #
    # This module provides helpers related to the Compliance Component
    module Compliance
      module_function

      # Get the Hostname of the Compliance Server
      #
      # @param node [Chef::Node] Chef Node object
      # @return hostname [String] The hostname of the Compliance server
      def compliance_server_hostname(node)
        Server::Helpers::Component.component_hostname(node, 'compliance')
      end

      # Returns the FQDN of the Compliance Server
      #
      # @param node [Chef::Node] Chef Node object
      # @return [String] Compliance FQDN
      def compliance_server_fqdn(node)
        @compliance_server_fqdn ||=
          Server::Helpers::Component.component_fqdn(node, 'compliance')
      end

      # Generates the Compliance Server Attributes
      #
      # @param node [Chef::Node] Chef Node object
      # @return [Hash] Compliance attributes for a machine resource
      def compliance_server_attributes(node)
        return {} unless compliance_enabled?(node)

        Chef::Mixin::DeepMerge.hash_only_merge(
          Server::Helpers::Component.component_attributes(node, 'compliance'),
          'chef-server-12' => {
            'compliance' => {
              'fqdn' => compliance_server_fqdn(node)
            }
          }
        )
      end

      # Activate the Compliance Component
      # This method will touch a lock file to activate the Compliance component
      #
      # @param node [Chef::Node] Chef Node object
      def activate_compliance(node)
        FileUtils.touch(compliance_lock_file(node))
      end

      # Compliance Lock File
      #
      # @param node [Chef::Node] Chef Node object
      # @return [String] The PATH of the Compliance lock file
      def compliance_lock_file(node)
        "#{Server::Helpers.provisioning_data_dir(node)}/compliance"
      end

      # Verify the state of the Compliance Component
      # If the lock file exist, then we have the Compliance component enabled,
      # otherwise it is NOT enabled yet.
      #
      # @param node [Chef::Node] Chef Node object
      # @return [Bool] The state of the Compliance component
      def compliance_enabled?(node)
        File.exist?(compliance_lock_file(node))
      end
    end
  end

  # Module that exposes multiple helpers
  module DSL
    # Hostname of the Compliance Server
    def compliance_server_hostname
      Server::Helpers::Compliance.compliance_server_hostname(node)
    end

    # FQDN of the Compliance Server
    def compliance_server_fqdn
      Server::Helpers::Compliance.compliance_server_fqdn(node)
    end

    # Compliance Server Attributes
    def compliance_server_attributes
      Server::Helpers::Compliance.compliance_server_attributes(node)
    end

    # Activate the Compliance Component
    def activate_compliance
      Server::Helpers::Compliance.activate_compliance(node)
    end

    # Compliance Lock File
    def compliance_lock_file
      Server::Helpers::Compliance.compliance_lock_file(node)
    end

    # Verify the state of the Compliance Component
    def compliance_enabled?
      Server::Helpers::Compliance.compliance_enabled?(node)
    end
  end
end
