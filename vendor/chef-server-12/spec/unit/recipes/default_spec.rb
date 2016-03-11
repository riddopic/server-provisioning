# encoding: UTF-8

require 'spec_helper'

describe "chef-server-12::default WITHOUT provisioner setup" do
  let(:chef_run) do
    runner = ChefSpec::SoloRunner.new(
      platform: 'redhat',
      version: '6.3',
      log_level: :error
    )
    runner.node.set['chef-server-12']['provisioner_setup'] = false
    Chef::Config.force_logger true
    runner.converge('recipe[chef-server-12::default]')
  end

  it 'install chef-server package' do
    expect(chef_run).to install_package('chef-server')
  end

  it 'creates chef-server.rb file' do
    expect(chef_run).to create_template('/etc/opscode/chef-server.rb')
  end

  it 'creates /etc/opscode directory' do
    expect(chef_run).to create_directory('/etc/opscode')
  end
end

describe "chef-server-12::default WITH provisioner setup" do
  before do
    stub_command("chef-server-ctl org-list | grep -w chef_provisioner").and_return(false)
    stub_command("chef-server-ctl user-list | grep -w provisioner").and_return(false)
  end

  let(:chef_run) do
    runner = ChefSpec::SoloRunner.new(
      platform: 'redhat',
      version: '6.3',
      log_level: :error
    )
    runner.node.set['chef-server-12']['provisioner_setup'] = true
    Chef::Config.force_logger true
    runner.converge('recipe[chef-server-12::default]')
  end

  it 'create provisioner organization' do
    expect(chef_run).to run_execute("Create #{chef_run.node['chef-server-12']['provisioner']['organization']} Organization")
  end

  it 'create provisioner user' do
    expect(chef_run).to run_execute("Create #{chef_run.node['chef-server-12']['provisioner']['user']} User")
  end

  it 'install chef-server package' do
    expect(chef_run).to install_package('chef-server')
  end

  it 'creates chef-server.rb file' do
    expect(chef_run).to create_template('/etc/opscode/chef-server.rb')
  end

  it 'creates /etc/opscode directory' do
    expect(chef_run).to create_directory('/etc/opscode')
  end
end
