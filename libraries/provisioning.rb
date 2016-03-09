# encoding: UTF-8

module Server
  #
  # Module to create instances of Provisioning Drivers
  #
  module Provisioning
    # Returns an instance of a driver given a driver type string.
    #
    # @param driver [String] a driver type, to be constantized
    # @return [Provisioning::Base] a driver instance
    def self.driver(driver, node)
      str_const = driver.split('_').map(&:capitalize).join

      klass = const_get(str_const)
      klass.new(node)
    rescue => e
      raise "Could not load the '#{driver}' driver: #{e.message}"
    end
  end
end

Chef::Recipe.send(:include, Server::Provisioning)
Chef::Resource.send(:include, Server::Provisioning)
