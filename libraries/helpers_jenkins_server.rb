# encoding: UTF-8

module Server
  module Helpers
    #
    # Jenkins Module
    #
    # This module provides helpers related to the Jenkins Server Component
    module JenkinsServer
      module_function

      # Get the Hostname of the Jenkins Server
      #
      # @param node [Chef::Node] Chef Node object
      # @return hostname [String] The hostname of the Jenkins Server
      def jenkins_server_hostname(node)
        Server::Helpers::Component.component_hostname(node, 'jenkins-server')
      end

      # Returns the FQDN of the Jenkins Server
      #
      # @param node [Chef::Node] Chef Node object
      # @return [String] Jenkins Server FQDN
      def jenkins_server_fqdn(node)
        @jenkins_server_fqdn ||=
          Server::Helpers::Component.component_fqdn(node, 'jenkins-server')
      end
    end
  end

  # Module that exposes multiple helpers
  module DSL
    # Hostname of the Jenkins Server
    def jenkins_server_hostname
      Server::Helpers::JenkinsServer.jenkins_server_hostname(node)
    end

    # FQDN of the Jenkins Server
    def jenkins_server_fqdn
      Server::Helpers::JenkinsServer.jenkins_server_fqdn(node)
    end
  end
end
