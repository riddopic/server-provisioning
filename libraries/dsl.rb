# encoding: UTF-8

require_relative 'helpers'
require_relative 'helpers_component'
require_relative 'helpers_chef_server'
require_relative 'helpers_supermarket'
require_relative 'helpers_analytics'

Chef::Recipe.send(:include, Server::DSL)
Chef::Resource.send(:include, Server::DSL)
Chef::Provider.send(:include, Server::DSL)
