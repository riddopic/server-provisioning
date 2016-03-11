# encoding: UTF-8

require 'spec_helper'

describe 'server-provisioning::setup_supermarket' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new do |node|
      node.set['server-provisioning'] = cluster_data
    end.converge(described_recipe)
  end

  before do
    allow_any_instance_of(Chef::Recipe)
      .to receive(:activate_supermarket).and_return(true)
    allow_any_instance_of(Chef::Recipe)
      .to receive(:provisioning_data_dir).and_return('/tmp')
  end

  it 'includes _settings recipe' do
    expect(chef_run).to include_recipe('server-provisioning::_settings')
  end

  it 'converge supermarket machine' do
    expect(chef_run).to converge_machine('supermarket-server-chefspec')
  end

  it 'activates supermarket through a ruby_block resource' do
    expect(chef_run).to run_ruby_block('Activate Supermarket')
  end

  it 'converge chef-server machine' do
    expect(chef_run).to converge_machine('chef-server-chefspec')
  end

  it 'download the file supermarket.json' do
    expect(chef_run).to download_machine_file('/etc/opscode/oc-id-applications/supermarket.json')
      .with_machine('chef-server-chefspec')
  end

  it 'download supermarket-server-cert' do
    expect(chef_run).to download_machine_file('supermarket-server-cert')
      .with_machine('supermarket-server-chefspec')
  end

  it 'add supermarket to the rendered knife.rb' do
    expect(chef_run).to create_template('/tmp/knife.rb')
  end
end
