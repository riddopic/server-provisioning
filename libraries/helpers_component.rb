# encoding: UTF-8

require 'chef/server_api'
require 'chef/node'

module Server
  module Helpers
    #
    # Component Module
    #
    # This module provide helpers for the components in Chef Provisioning
    module Component
      module_function

      # Extract the Chef::Node object of the component
      #
      # @param node [Chef::Node] Chef Node object
      # @param component [String] The name of the component
      # @return node [Chef::Node] Chef Node object
      def component_node(node, component)
        Chef::Node.json_create(
          Chef::ServerAPI.new(
            Server::Helpers::ChefServer.chef_server_config(node)[:chef_server_url],
            client_name: Server::Helpers::ChefServer.chef_server_config(node)[:options][:client_name],
            signing_key_filename: Server::Helpers::ChefServer.chef_server_config(node)[:options][:signing_key_filename]
          ).get("nodes/#{component_hostname(node, component)}")
        )
      end

      # Returns the FQDN of the component
      # If the component_node is specified, we use it. Otherwise extract it
      #
      # @param node [Chef::Node] Chef Node object
      # @param component [String] The name of the component
      # @param component_node [Chef::Node] The Chef Node object of the component
      # @return [String]
      def component_fqdn(node, component, c_node = component_node(node, component))
        node['provisioning'][component]['fqdn'] ||
          node['provisioning'][component]['host'] ||
          Server::Helpers.get_ip(node, c_node)
      end

      # Returns the Hostname of the component
      # If there is an `id` it means that this component consist in more than
      # one machine (multiple components of the same kind)
      #
      # @param node [Chef::Node] Chef Node object
      # @param component [String] The name of the component
      # @return [String]
      def component_hostname(node, component, id = nil)
        Server::Helpers.check_attribute?(
          node['provisioning'][component],
          "node['provisioning']['#{component}']"
        )
        if id
          multiple_component_hostname(node, component, id)
        else
          single_component_hostname(node, component)
        end
      end

      # Returns the Hostname of the a single component
      # If the component does not have already a hostname we will generate one
      # and save it
      #
      # @param node [Chef::Node] Chef Node object
      # @param component [String] The name of the component
      # @return [String] component hostname
      def single_component_hostname(node, component)
        unless hostname?(get_component(node, component))
          component_prefix = component.eql?('chef-server') ? 'chef-server' : "#{component}-server"
          node.set['provisioning'][component]['hostname'] = "#{component_prefix}-#{Server::Helpers.chef_provisioning_id(node)}"
        end

        get_component(node, component)['hostname']
      end

      # Returns the Hostname of a multiple component with an id
      # Where the `id` will be a pointer of one of the components that we
      # will work with. First we validate if it has a 'hostname', if not we
      # search for a 'hostname_prefix', but if we do not find any of them,
      # we will generate and save them.
      #
      # @param node [Chef::Node] Chef Node object
      # @param component [String] The name of the component
      # @param id [String] The id to point to an specific component
      # @return [String] component hostname
      def multiple_component_hostname(node, component, id)
        unless hostname?(get_component(node, component, id))
          unless node['provisioning'][component]['hostname_prefix']
            node.set['provisioning'][component]['hostname_prefix'] = "node-#{Server::Helpers.chef_provisioning_id(node)}"
          end
          node.set['provisioning'][component][id]['hostname'] = "#{node['provisioning'][component]['hostname_prefix']}-#{id}"
        end

        get_component(node, component, id)['hostname']
      end

      # Returns the hostname from a Hash
      #
      # @param component [String] The component
      # @return [String] hostname
      def hostname?(component)
        component['hostname']
      end

      # Extract a component from a Chef::Node Object
      #
      # @param node [Chef::Node] Chef Node object
      # @param name [String] The name of a component
      # @param id [String] The id to point to an specific component
      # @return [String] hostname
      def get_component(node, name, id = nil)
        if id
          return {} unless node['provisioning'][name][id]
          node['provisioning'][name][id]
        else
          node['provisioning'][name]
        end
      end

      # Returns the component attributes
      # In the case of additional attributes specified, if there aren't
      # we will return an empty Hash
      #
      # @param node [Chef::Node] Chef Node object
      # @param name [String] The name of a component
      # @return [Hash] of attributes from a component
      def component_attributes(node, name)
        node['provisioning'][name]['attributes']
      rescue
        {}
      end

      # Returns the security group ID for the host.
      #
      # @param host [String] The name of a component
      # @return [String] security group ID
      def security_group_ids(host)
        ec2.security_groups.find { |s| s.group_name =~ /#{host}/ }.id
      end

      # Returns the subnet ID for the host.
      #
      # @param host [String] The name of a component
      # @return [String] subnet ID
      def subnet_id(zone)
        ec2.subnets.find { |s| s.availability_zone =~ /#{zone}/ }.id
      end

      class << self
        def ec2
          require 'aws-sdk'
          @ec2 ||= Aws::EC2::Resource.new(
            region: 'us-west-2',
            credentials: Aws::SharedCredentials.new(
              path: File.expand_path('~/.aws/credentials')
            )
          )
        end
      end
    end
  end

  # Module that exposes multiple helpers
  module DSL
    # Extra component attributes
    def component_attributes(component)
      Server::Helpers::Component.component_attributes(node, component)
    end

    # The component node object
    def component_node(component)
      Server::Helpers::Component.component_node(node, component)
    end

    # The component fqdn
    def component_fqdn(component, component_node = nil)
      Server::Helpers::Component.component_fqdn(node, component, component_node)
    end

    # The component hostname
    def component_hostname(component, id = nil)
      Server::Helpers::Component.component_hostname(node, component, id)
    end
  end
end
