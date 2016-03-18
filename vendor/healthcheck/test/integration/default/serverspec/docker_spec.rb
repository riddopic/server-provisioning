# encoding: UTF-8

require 'spec_helper'

ports = { docker_rest_api: 2375 }

# Docker
describe package('lxc-docker') do
  it { should be_installed }
end

# Docker service
describe service('docker') do
  it { should be_enabled }
  it { should be_running }
end

describe port(ports[:docker_rest_api]) do
  it { should be_listening }
end

describe command('docker images') do
  let(:disable_sudo) { true }
  it { should return_stdout /REPOSITORY.*/ }
end
