# encoding: UTF-8

require_relative '_base'

module Server
  module Provisioning
    #
    # Ssh class for SsH Provisioning Driver
    #
    # Specify all the methods a Provisioning Driver should implement
    class Ssh < Server::Provisioning::Base
      attr_accessor :node
      attr_accessor :prefix
      attr_accessor :ssh_username
      alias username ssh_username

      # Create a new Provisioning Driver Abstraction
      #
      # @param node [Chef::Node]
      def initialize(node)
        require 'chef/provisioning/ssh_driver'

        Server::Helpers.check_attribute?(
          node['provisioning'][driver],
          "node['provisioning']['#{driver}']"
        )
        @node = node
        @prefix = 'sudo '
        @driver_hash = @node['provisioning'][driver]

        @driver_hash.each do |attr, value|
          singleton_class.class_eval { attr_accessor attr }
          instance_variable_set("@#{attr}", value)
        end

        return unless @password && @key_file
        raise 'You should not specify both key_file and password.'
      end

      # Return the machine options to use.
      #
      # @return [Hash] the machine_options for the specific driver
      def machine_options
        {
          convergence_options: {
            bootstrap_proxy: @bootstrap_proxy,
            chef_config: @chef_config,
            chef_version: @chef_version,
            install_sh_path: @install_sh_path
          },
          transport_options: {
            username: @ssh_username,
            ssh_options: {
              user: @ssh_username,
              password: @password,
              keys: @key_file.nil? ? [] : [@key_file]
            },
            options: {
              prefix: @prefix
            }
          }
        }
      end

      # Create a array of machine_options specifics to a component
      #
      # @param component [String] component name
      # @param count [Integer] component number
      # @return [Array] specific machine_options for the specific component
      def specific_machine_options(component, count = nil)
        return [] unless @node['provisioning'][component]
        options = []
        if count
          if @node['provisioning'][component][count.to_s]['host']
            options << { transport_options: { host: @node['provisioning'][component][count.to_s]['host'] } }
          elsif @node['provisioning'][component][count.to_s]['ip']
            options << { transport_options: { ip_address: @node['provisioning'][component][count.to_s]['ip'] } }
          end if @node['provisioning'][component][count.to_s]
        elsif @node['provisioning'][component]['host']
          options << { transport_options: { host: @node['provisioning'][component]['host'] } }
        elsif @node['provisioning'][component]['ip']
          options << { transport_options: { ip_address: @node['provisioning'][component]['ip'] } }
        end
        # Specify more specific machine_options to add
        options
      end

      # Return the Provisioning Driver Name.
      #
      # @return [String] the provisioning driver name
      def driver
        'ssh'
      end

      # Return the ipaddress from the machine.
      #
      # @param node [Chef::Node]
      # @return [String] an ipaddress
      def ipaddress(node)
        node['ipaddress']
      end
    end
  end
end
