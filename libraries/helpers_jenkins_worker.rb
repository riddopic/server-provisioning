# encoding: UTF-8

module Server
  module Helpers
    #
    # Jenkins Module
    #
    # This module provides helpers related to the Jenkins Workers Component
    module JenkinsWorkers
      module_function

      # Get the Hostname of the Jenkins Workers
      #
      # @param node [Chef::Node] Chef Node object
      # @return hostname [String] The hostname of the Jenkins Workers
      def jenkins_worker_hostname(node)
        Server::Helpers::Component.component_hostname(node, 'jenkins-worker')
      end

      # Returns the FQDN of the Jenkins Workers
      #
      # @param node [Chef::Node] Chef Node object
      # @return [String] Jenkins Workers FQDN
      def jenkins_worker_fqdn(node)
        @jenkins_worker_fqdn ||=
          Server::Helpers::Component.component_fqdn(node, 'jenkins-worker')
      end
    end
  end

  # Module that exposes multiple helpers
  module DSL
    # Hostname of the Jenkins Workers
    def jenkins_worker_hostname
      Server::Helpers::JenkinsServer.jenkins_worker_hostname(node)
    end

    # FQDN of the Jenkins Workers
    def jenkins_worker_fqdn
      Server::Helpers::JenkinsServer.jenkins_worker_fqdn(node)
    end
  end
end
