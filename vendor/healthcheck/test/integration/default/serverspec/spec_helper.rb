# encoding: UTF-8

require 'serverspec'
require 'pathname'
require 'net/ssh'
require 'highline/import'

include Serverspec::Helper::Exec
include Serverspec::Helper::DetectOS

RSpec.configure do |config|
  config.color = true
  config.tty = true
  config.formatter = :documentation
  config.before :all do
    config.os = backend(Serverspec::Commands::Base).check_os
    config.path = '/sbin:/usr/sbin'
  end
end
