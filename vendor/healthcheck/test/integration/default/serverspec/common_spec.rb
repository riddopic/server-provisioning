# encoding: UTF-8

require 'spec_helper'

describe service('ssh') do
  it { should be_enabled }
  it { should be_running }
end

describe service('ntp') do
  it { should be_enabled }
  it { should be_running }
end

describe package('git') do
  it { should be_installed }
end
