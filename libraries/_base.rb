# encoding: UTF-8

module Server
  module Provisioning
    #
    # Base class for a Provisioning Abstraction.
    #
    # Specify all the methods a Provisioning Driver should implement
    class Base
      # Create a new Provisioning Driver Abstraction
      #
      # @param node [Chef::Node]
      def initialize(node) # rubocop:disable Lint/UnusedMethodArgument
        raise "#{self.class}#initialize must be implemented"
      end

      # Return the machine options to use.
      #
      # @return [Hash] the machine_options for the specific driver
      def machine_options
        raise "#{self.class}#machine_options must be implemented"
      end

      # Create a array of machine_options specifics to a component
      #
      # @param component [String] component name
      # @param count [Integer] component number
      # @return [Array] specific machine_options for the specific component
      def specific_machine_options(_component, _count = nil)
        raise "#{self.class}#specific_machine_options must be implemented"
      end

      # Return the Provisioning Driver Name.
      #
      # @return [String] the provisioning driver name
      def driver
        raise "#{self.class}#driver must be implemented"
      end

      # Return the ipaddress from the machine.
      #
      # @param node [Chef::Node]
      # @return [String] an ipaddress
      def ipaddress(node, use_private_ip_for_ssh = false) # rubocop:disable Lint/UnusedMethodArgument
        raise "#{self.class}#ipaddress must be implemented"
      end

      # Return the username of the Provisioning Driver.
      #
      # @return [String] the username
      def username
        'root'
      end
    end
  end
end
