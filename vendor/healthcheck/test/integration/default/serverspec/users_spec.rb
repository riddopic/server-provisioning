# encoding: UTF-8

require 'spec_helper'

describe command('whoami') do
  let(:disable_sudo) { true }
  it { should return_stdout 'healthinspector' }
end

describe user('healthinspector') do
  it { should belong_to_group 'docker' }
end
