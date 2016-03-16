# encoding: UTF-8

require 'spec_helper'

describe 'provisioning::setup_chef_server' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new do |node|
      node.set['provisioning'] = cluster_data
    end.converge(described_recipe)
  end

  before do
    allow_any_instance_of(Chef::Resource).to receive(:provisioning_data_dir)
      .and_return('/repo/provisioner-cluster-dir')
  end

  it 'includes _settings recipe' do
    expect(chef_run).to include_recipe('provisioning::_settings')
  end

  it 'converge chef server machine' do
    expect(chef_run).to converge_machine('chef-server-chefspec')
  end

  it 'download the validator.pem' do
    expect(chef_run).to download_machine_file('/tmp/validator.pem')
      .with_machine('chef-server-chefspec')
  end

  it 'download the provisioner.pem' do
    expect(chef_run).to download_machine_file('/tmp/provisioner.pem')
      .with_machine('chef-server-chefspec')
  end

  it 'download chef-server-cert' do
    expect(chef_run).to download_machine_file('chef-server-cert')
      .with_machine('chef-server-chefspec')
  end

  it 'upload provisioner cookbooks through a ruby_block' do
    expect(chef_run).to run_ruby_block('upload provisioner cookbooks')
  end
end
