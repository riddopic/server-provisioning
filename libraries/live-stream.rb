# encoding: UTF-8

require 'chef/log'
require 'chef/provider'

class Chef
  class Provider
    # Stream shell command output.
    class LiveStream < Chef::Provider::Execute
      provides :execute, override: true
      Chef::Config[:live_stream] ||= true

      def opts
        opts = {}
        opts[:timeout] = timeout
        opts[:returns] = returns if returns
        opts[:environment] = environment if environment
        opts[:user] = user if user
        opts[:group] = group if group
        opts[:cwd] = cwd if cwd
        opts[:umask] = umask if umask
        opts[:log_level] = :info
        opts[:log_tag] = new_resource.to_s
        opts[:live_stream] = STDOUT if live_stream?
        opts
      end

      def live_stream?
        return false if sensitive?
        if Chef::Config[:live_stream] || (STDOUT.tty? && !Chef::Config[:daemon] && Chef::Log.info?)
          true
        else
          false
        end
      end
    end
  end
end

%w[debian ubuntu fedora redhat centos].each do |platform|
  Chef::Platform.set plaform: platform.to_sym,
    resource: :execute,
    provider: Chef::Provider::LiveStream
end
